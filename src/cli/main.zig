pub const Command = enum {
    help,
};

pub const params = clap.parseParamsComptime(
    \\-l, --list     List templates
    \\-u, --update   Update all templates by fetching them from gitignore.io
    \\-w, --write    Write to .gitignore file instead of stdout
    \\-f, --force    Forcefully overwrite existing .gitignore file
    \\-v, --version  Display version information
    \\<string>       Command and/or templates
    \\
);

pub const Args = clap.ResultEx(clap.Help, &params, clap.parsers.default);

pub fn invoke(gpa: mem.Allocator, iter: *process.ArgIterator, res: *const Args) !void {
    var c = Chameleon.initRuntime(.{ .allocator = gpa });
    defer c.deinit();

    const templates = templates_are: {
        var templates: std.ArrayListUnmanaged([]const u8) = .empty;
        defer templates.deinit(gpa);

        while (iter.next()) |template| {
            try templates.append(gpa, template);
        }

        break :templates_are try templates.toOwnedSlice(gpa);
    };
    defer gpa.free(templates);

    if (res.args.list == 0 and
        res.args.update == 0 and
        res.args.write == 0 and
        res.args.force == 0 and
        res.args.version == 0 and
        templates.len == 0)
    {
        defer process.exit(0);
        try cli.main.help(io.getStdErr().writer());
    }

    if (res.args.version != 0) {
        defer process.exit(0);
        try version(io.getStdErr().writer(), res);
    }

    const ignore_site: lib.IgnoreSite = .default;

    const config_path = try cli.fs.getConfigPath(gpa);
    defer gpa.free(config_path);
    const cache_path = try cli.fs.getCachePath(gpa, config_path);
    defer gpa.free(cache_path);

    if (res.args.update != 0) {
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

    var ignore_files: lib.IgnoreFiles = ignore_files_are: {
        const file = try fs.openFileAbsolute(cache_path, .{ .mode = .read_only });
        break :ignore_files_are lib.IgnoreFiles.parseFromReader(gpa, file.reader());
    } catch |err| {
        defer process.exit(1);
        try cli.print.err(&c, "{any}\n", .{err});
    };
    defer ignore_files.deinit(gpa);

    if (res.args.update != 0 and templates.len == 0) {
        process.exit(0);
    }

    const output_file: fs.File = output_is: {
        if (res.args.write != 0) {
            if (cli.fs.gitIgnoreExists()) {
                if (res.args.force != 0) {
                    try cli.print.info(&c, "appending results to '.gitignore'\n", .{});
                    const file = try fs.cwd().openFile(".gitignore", .{ .mode = .read_write });
                    const eof = try file.getEndPos();
                    try file.seekTo(eof);
                    break :output_is file;
                } else {
                    break :output_is error.ExistsUseForce;
                }
            } else {
                try cli.print.info(&c, "no '.gitignore' file found, creating...\n", .{});
                break :output_is try fs.cwd().createFile(".gitignore", .{});
            }
        }
        break :output_is io.getStdOut();
    } catch |err| switch (err) {
        error.ExistsUseForce => {
            defer process.exit(1);
            try cli.print.warn(&c, "'.gitignore' already exists, use '-f' to force write\n", .{});
        },
    };
    defer output_file.close();

    var bw = io.bufferedWriter(output_file.writer());
    const stdout = bw.writer();

    if (res.args.list != 0) {
        try ignore_files.writeTemplateNames(gpa, stdout, templates);
    } else {
        try ignore_files.writeTemplates(gpa, stdout, templates);
    }

    _ = try bw.flush();
}

pub fn help(writer: anytype) !void {
    _ = try writer.write("usage: git-ignore [flags] [command] [<args>]\n");
    try clap.help(
        writer,
        clap.Help,
        &params,
        .{
            .description_on_new_line = false,
            .indent = 2,
            .spacing_between_parameters = 0,
        },
    );
}

pub fn version(writer: anytype, res: *const Args) !void {
    switch (res.args.version) {
        1 => try writer.print("{s}\n", .{lib.version}),
        2 => try writer.print("{s}-{s}-{s}", .{
            lib.version,
            @tagName(builtin.target.os.tag),
            @tagName(builtin.target.cpu.arch),
        }),
        else => try writer.print("{s}-{s}-{s}-{s}", .{
            lib.version,
            @tagName(builtin.target.os.tag),
            @tagName(builtin.target.cpu.arch),
            switch (builtin.mode) {
                .Debug => "debug",
                .ReleaseSafe => "safe",
                .ReleaseFast => "fast",
                .ReleaseSmall => "small",
            },
        }),
    }
}

const std = @import("std");
const builtin = @import("builtin");
const fs = std.fs;
const io = std.io;
const mem = std.mem;
const process = std.process;

const Chameleon = @import("chameleon");
const clap = @import("clap");

const cli = @import("cli.zig");

const lib = @import("git_ignore_lib");
