pub fn main() !void {
    var gpa_state = heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_state.allocator();
    defer _ = gpa_state.deinit();

    var c = Chameleon.initRuntime(.{ .allocator = gpa });
    defer c.deinit();

    const args = cli.main.Arguments.init(gpa) catch |err| switch (err) {
        cli.main.ParseError.ForceWithoutWrite => {
            defer process.exit(2);
            try cli.print.err(&c, "--force can only be used with --write\n", .{});
        },
        cli.main.ParseError.EmptyArguments => {
            defer process.exit(0);
            try cli.main.help(io.getStdErr().writer());
        },
        else => return err,
    };
    defer args.deinit(gpa);

    if (args.command) |command| {
        switch (command) {
            .help => {
                defer process.exit(0);
                try cli.main.help(io.getStdErr().writer());
            },
        }
    }

    if (args.version != 0) {
        defer process.exit(0);
        try cli.main.version(io.getStdErr().writer(), &args);
    }

    const ignore_site: lib.IgnoreSite = .default;

    const config_path = try cli.fs.getConfigPath(gpa);
    defer gpa.free(config_path);
    const cache_path = try cli.fs.getCachePath(gpa, config_path);
    defer gpa.free(cache_path);

    if (args.update) {
        ignore_site.download(gpa, cache_path) catch |err| {
            defer process.exit(1);
            try cli.print.err(&c, "{any}\n", .{err});
        };
        try cli.print.info(&c, "Update successful!\n", .{});
    } else if (cli.fs.existsAbsolute(cache_path)) {
        try cli.print.info(&c, "You are using cached results, pass '-u' to update the cache.\n", .{});
    } else {
        try cli.print.warn(&c, "Cache directory or ignore file not found, attempting update.\n", .{});
        ignore_site.download(gpa, cache_path) catch |err| {
            defer process.exit(1);
            try cli.print.err(&c, "{any}\n", .{err});
        };
    }

    var ignore_files: lib.IgnoreFiles = blk: {
        const file = try fs.openFileAbsolute(cache_path, .{ .mode = .read_only });
        break :blk lib.IgnoreFiles.parseFromReader(gpa, file.reader());
    } catch |err| {
        defer process.exit(1);
        try cli.print.err(&c, "{any}\n", .{err});
    };
    defer ignore_files.deinit(gpa);

    if (args.update and args.templates.len == 0) {
        process.exit(0);
    }

    const output_file: fs.File = blk: {
        if (args.write) {
            if (cli.fs.gitIgnoreExists()) {
                if (args.force) {
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

    if (args.list) {
        try ignore_files.writeTemplateNames(gpa, stdout, args.templates);
    } else {
        try ignore_files.writeTemplates(gpa, stdout, args.templates);
    }

    _ = try bw.flush();
}

const std = @import("std");
const builtin = @import("builtin");
const fs = std.fs;
const heap = std.heap;
const io = std.io;
const process = std.process;

const Chameleon = @import("chameleon");

const cli = @import("cli/cli.zig");

const lib = @import("git_ignore_lib");
