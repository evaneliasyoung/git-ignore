pub fn main() !void {
    var gpa_state = heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_state.allocator();
    defer _ = gpa_state.deinit();

    var c = Chameleon.initRuntime(.{ .allocator = gpa });
    defer c.deinit();

    var iter = try process.ArgIterator.initWithAllocator(gpa);
    defer iter.deinit();

    _ = iter.next();

    var diag = clap.Diagnostic{};
    var res = clap.parseEx(clap.Help, &cli.main.params, clap.parsers.default, &iter, .{
        .diagnostic = &diag,
        .allocator = gpa,
        .terminating_positional = 0,
    }) catch |err| {
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    const main_args = cli.main.Arguments.init(&res);

    if (main_args.force and !main_args.write) {
        defer process.exit(2);
        try cli.print.err(&c, "--force can only be used with --write\n", .{});
    }

    if (main_args.version) {
        defer process.exit(0);
        std.debug.print("git-ignore version {s}.{s}.{s}\n", .{
            lib.version,
            @tagName(builtin.os.tag),
            @tagName(builtin.cpu.arch),
        });
    }

    var templates: std.ArrayListUnmanaged([]const u8) = .empty;
    defer templates.deinit(gpa);

    if (res.positionals[0]) |maybe_command| {
        if (meta.stringToEnum(cli.main.SubCommands, maybe_command)) |command| {
            switch (command) {
                .help => std.debug.print("TODO: remove once there are real commands (help)\n", .{}),
            }
        } else {
            try templates.append(gpa, maybe_command);
        }
    }
    while (iter.next()) |template| {
        try templates.append(gpa, template);
    }

    const ignore_site: lib.IgnoreSite = .default;

    const config_path = try cli.fs.getConfigPath(gpa);
    defer gpa.free(config_path);
    const cache_path = try cli.fs.getCachePath(gpa, config_path);
    defer gpa.free(cache_path);

    if (main_args.update) {
        ignore_site.download(gpa, cache_path) catch |err| {
            defer process.exit(1);
            cli.print.err(&c, "{any}\n", .{err}) catch {};
        };
        try cli.print.info(&c, "Update successful!\n", .{});
    } else if (cli.fs.existsAbsolute(cache_path)) {
        try cli.print.info(&c, "You are using cached results, pass '-u' to update the cache.\n", .{});
    } else {
        try cli.print.warn(&c, "Cache directory or ignore file not found, attempting update.\n", .{});
        ignore_site.download(gpa, cache_path) catch |err| {
            defer process.exit(1);
            cli.print.err(&c, "{any}\n", .{err}) catch {};
        };
    }

    var ignore_files: lib.IgnoreFiles = blk: {
        const file = try fs.openFileAbsolute(cache_path, .{ .mode = .read_only });
        break :blk lib.IgnoreFiles.parseFromReader(gpa, file.reader());
    } catch |err| {
        defer process.exit(1);
        cli.print.err(&c, "{any}\n", .{err}) catch {};
    };
    defer ignore_files.deinit(gpa);

    if (main_args.update and templates.items.len == 0) {
        process.exit(0);
    }

    const output_file: fs.File = blk: {
        if (main_args.write) {
            if (cli.fs.gitIgnoreExists()) {
                if (main_args.force) {
                    try cli.print.info(&c, "appending results to '.gitignore'\n", .{});
                    const file = try fs.cwd().openFile(".gitignore", .{ .mode = .read_write });
                    const eof = try file.getEndPos();
                    try file.seekTo(eof);
                    break :blk file;
                } else {
                    break :blk error.ExistsUseForce;
                }
            } else {
                try cli.print.info(&c, "no '.gitignore' file found, creating...\n", .{});
                break :blk try fs.cwd().createFile(".gitignore", .{});
            }
        }
        break :blk io.getStdOut();
    } catch |err| switch (err) {
        error.ExistsUseForce => {
            defer process.exit(1);
            try cli.print.warn(&c, "'.gitignore' already exists, use '-f' to force write\n", .{});
        },
    };
    defer output_file.close();

    var bw = io.bufferedWriter(output_file.writer());
    const stdout = bw.writer();

    if (main_args.list) {
        try ignore_files.writeTemplateNames(gpa, stdout, templates.items);
    } else {
        try ignore_files.writeTemplates(gpa, stdout, templates.items);
    }

    _ = try bw.flush();
}

const std = @import("std");
const builtin = @import("builtin");
const fs = std.fs;
const heap = std.heap;
const io = std.io;
const meta = std.meta;
const process = std.process;

const clap = @import("clap");
const Chameleon = @import("chameleon");

const cli = @import("cli/cli.zig");

const lib = @import("git_ignore_lib");
