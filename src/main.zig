pub fn main() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_state.allocator();
    defer _ = gpa_state.deinit();

    var c = Chameleon.initRuntime(.{ .allocator = gpa });
    defer c.deinit();

    var iter = try std.process.ArgIterator.initWithAllocator(gpa);
    defer iter.deinit();

    _ = iter.next();

    var diag = clap.Diagnostic{};
    var res = clap.parseEx(clap.Help, &cli.main.params, clap.parsers.default, &iter, .{
        .diagnostic = &diag,
        .allocator = gpa,
        .terminating_positional = 0,
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    const main_args = cli.main.Arguments.init(&res);

    if (main_args.force and !main_args.write) {
        defer std.process.exit(2);
        try cli.print.err(&c, "--force can only be used with --write\n", .{});
    }

    var templates: std.ArrayListUnmanaged([]const u8) = .empty;
    defer templates.deinit(gpa);

    if (res.positionals[0]) |maybe_command| {
        if (std.meta.stringToEnum(cli.main.SubCommands, maybe_command)) |command| {
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
            defer std.process.exit(1);
            cli.print.err(&c, "{any}\n", .{err}) catch {};
        };
        try cli.print.info(&c, "Update successful!\n", .{});
    } else if (cli.fs.existsAbsolute(cache_path)) {
        try cli.print.info(&c, "You are using cached results, pass '-u' to update the cache.\n", .{});
    } else {
        try cli.print.warn(&c, "Cache directory or ignore file not found, attempting update.\n", .{});
        ignore_site.download(gpa, cache_path) catch |err| {
            defer std.process.exit(1);
            cli.print.err(&c, "{any}\n", .{err}) catch {};
        };
    }

    if (main_args.update and templates.items.len == 0) {
        std.process.exit(0);
    }

    // TODO: writer logic

    std.debug.print("{any}\n", .{templates});
}

const std = @import("std");
const clap = @import("clap");
const Chameleon = @import("chameleon");

const cli = @import("cli/cli.zig");

const lib = @import("git_ignore_lib");
