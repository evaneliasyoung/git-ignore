const std = @import("std");
const builtin = @import("builtin");

const Chameleon = @import("chameleon");
const clap = @import("clap");

const cli = @import("cli.zig");
const lib = @import("git_ignore");

pub const Command = enum {
    help,
    alias,
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

pub const Args = clap.ResultEx(clap.Help, &cli.main.params, clap.parsers.default);

pub fn invoke(
    io: std.Io,
    gpa: std.mem.Allocator,
    environ: *std.process.Environ.Map,
    c: *Chameleon.RuntimeChameleon,
    writer: *std.Io.Writer,
    iter: *std.process.Args.Iterator,
    res: *const Args,
) !void {
    const templates = templates_are: {
        var templates: std.ArrayList([]const u8) = .empty;
        defer templates.deinit(gpa);

        if (res.positionals[0]) |not_a_command| {
            try templates.append(gpa, not_a_command);
        }
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
        defer std.process.exit(0);
        try cli.help.main(c, writer);
    }

    if (res.args.version != 0) {
        defer std.process.exit(0);
        try cli.main.version(writer, res);
    }

    const ignore_site: lib.IgnoreSite = .default;

    const config_path = try cli.fs.getConfigPath(io, gpa, environ);
    defer gpa.free(config_path);

    const cache_path = try cli.fs.getCachePath(io, gpa, environ, config_path);
    defer gpa.free(cache_path);
    const aliases_path = try cli.fs.getAliasesPath(io, gpa, environ, config_path);
    defer gpa.free(aliases_path);

    if (res.args.update != 0) {
        ignore_site.download(io, gpa, cache_path) catch |err| {
            defer std.process.exit(1);
            try cli.print.err(io, c, "{any}\n", .{err});
        };
        try cli.print.info(io, c, "Update successful!\n", .{});
    } else if (cli.fs.existsAbsolute(io, cache_path)) {
        try cli.print.info(io, c, "You are using cached results, pass '-u' to update the cache.\n", .{});
    } else {
        try cli.print.warn(io, c, "Cache directory or ignore file not found, attempting update.\n", .{});
        ignore_site.download(io, gpa, cache_path) catch |err| {
            defer std.process.exit(1);
            try cli.print.err(io, c, "{any}\n", .{err});
        };
    }

    var ignore_files: lib.IgnoreFiles = ignore_files_are: {
        const file = try std.Io.Dir.openFileAbsolute(io, cache_path, .{ .mode = .read_only });
        defer file.close(io);
        break :ignore_files_are lib.IgnoreFiles.parseFromFile(io, gpa, file);
    } catch |err| {
        defer std.process.exit(1);
        try cli.print.err(io, c, "{any}\n", .{err});
    };
    defer ignore_files.deinit(gpa);

    if (res.args.update != 0 and templates.len == 0) {
        std.process.exit(0);
    }

    var ignore_aliases: lib.IgnoreAliases = ignore_aliases_are: {
        if (cli.fs.existsAbsolute(io, aliases_path)) {
            try cli.print.info(io, c, "Found aliases file!\n", .{});
            const file = try std.Io.Dir.openFileAbsolute(io, aliases_path, .{ .mode = .read_only });
            defer file.close(io);
            break :ignore_aliases_are lib.IgnoreAliases.parseFromFile(io, gpa, file);
        } else {
            try cli.print.warn(io, c, "Cache directory or aliases file not found, creating...\n", .{});
            break :ignore_aliases_are lib.IgnoreAliases.empty;
        }
    } catch |err| {
        defer std.process.exit(1);
        try cli.print.err(io, c, "{any}\n", .{err});
    };
    defer ignore_aliases.deinit(gpa);

    const expanded_templates = try ignore_aliases.expandAliases(gpa, templates);
    defer gpa.free(expanded_templates);

    const output_file: std.Io.File = output_is: {
        if (res.args.write != 0) {
            if (cli.fs.gitIgnoreExists(io)) {
                if (res.args.force != 0) {
                    try cli.print.info(io, c, "appending results to '.gitignore'\n", .{});
                    const file = try std.Io.Dir.cwd().openFile(io, ".gitignore", .{ .mode = .read_write });
                    break :output_is file;
                } else {
                    break :output_is error.ExistsUseForce;
                }
            } else {
                try cli.print.info(io, c, "no '.gitignore' file found, creating...\n", .{});
                break :output_is try std.Io.Dir.cwd().createFile(io, ".gitignore", .{});
            }
        }
        break :output_is std.Io.File.stdout();
    } catch |err| switch (err) {
        error.ExistsUseForce => {
            defer std.process.exit(1);
            try cli.print.warn(io, c, "'.gitignore' already exists, use '-f' to force write\n", .{});
        },
    };
    defer output_file.close(io);

    var buf: [1024]u8 = undefined;
    var output_writer = output_file.writer(io, &buf);
    {
        const eof = try output_file.length(io);
        try output_writer.seekTo(eof);
    }

    if (res.args.list != 0) {
        try ignore_files.writeTemplateNames(gpa, &output_writer.interface, expanded_templates);
    } else {
        try ignore_files.writeTemplates(gpa, &output_writer.interface, expanded_templates);
    }

    _ = try output_writer.interface.flush();
}

pub fn version(writer: *std.Io.Writer, res: *const Args) !void {
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
