const main_params = clap.parseParamsComptime(
    \\-l, --list    List templates
    \\-u, --update  Update all templates by fetching them from gitignore.io
    \\-w, --write   Write to .gitignore file instead of stdout
    \\-f, --force   Forcefully overwrite existing .gitignore file
    \\<string>
    \\
);

pub const SubCommands = enum {
    help,
};

pub const MainArguments = struct {
    list: bool,
    update: bool,
    write: bool,
    force: bool,
};

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
    var res = clap.parseEx(clap.Help, &main_params, clap.parsers.default, &iter, .{
        .diagnostic = &diag,
        .allocator = gpa,
        .terminating_positional = 0,
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    const main_args = MainArguments{
        .list = res.args.list != 0,
        .update = res.args.update != 0,
        .write = res.args.write != 0,
        .force = res.args.force != 0,
    };

    if (main_args.force and !main_args.write) {
        defer std.process.exit(2);
        try cli.print.err(&c, "--force can only be used with --write\n", .{});
    }

    var templates: std.ArrayListUnmanaged([]const u8) = .empty;
    defer templates.deinit(gpa);

    if (res.positionals[0]) |maybe_command| {
        if (std.meta.stringToEnum(SubCommands, maybe_command)) |command| {
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

    // TODO: update logic

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
