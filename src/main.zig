const std = @import("std");
const heap = std.heap;
const io = std.io;
const meta = std.meta;
const process = std.process;

const clap = @import("clap");

const cli = @import("cli/cli.zig");

pub fn main() !void {
    var gpa_state = heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_state.allocator();
    defer _ = gpa_state.deinit();

    var iter = try process.ArgIterator.initWithAllocator(gpa);
    defer iter.deinit();

    _ = iter.next();

    var diag = clap.Diagnostic{};
    var res: cli.main.Args = clap.parseEx(clap.Help, &cli.main.params, clap.parsers.default, &iter, .{
        .diagnostic = &diag,
        .allocator = gpa,
        .terminating_positional = 0,
    }) catch |err| {
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.positionals[0]) |maybe_command| {
        if (meta.stringToEnum(cli.main.Command, maybe_command)) |command| {
            switch (command) {
                .help => {
                    defer process.exit(0);
                    try cli.help.invoke(gpa, &iter);
                },
                .alias => {
                    defer process.exit(0);
                    try cli.alias.invoke(gpa, &iter);
                },
            }
        }
    }
    try cli.main.invoke(gpa, &iter, &res);
}

test {
    _ = @import("cli/cli.zig");
}
