pub const params = clap.parseParamsComptime(
    \\-l, --list    List aliases
    \\-a, --add     Add an alias
    \\-r, --remove  Remove an alias
);

pub const Args = clap.ResultEx(clap.Help, &params, clap.parsers.default);

pub fn invoke(gpa: mem.Allocator, iter: *process.ArgIterator) !void {
    var diag = clap.Diagnostic{};
    var res: Args = clap.parseEx(clap.Help, &params, clap.parsers.default, iter, .{
        .diagnostic = &diag,
        .allocator = gpa,
        .terminating_positional = 0,
    }) catch |err| {
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    std.debug.print("gpa: {any}\n", .{gpa});
    std.debug.print("iter: {any}\n", .{iter});
    std.debug.print("res: {any}\n", .{res});
}

const std = @import("std");
const builtin = @import("builtin");
const io = std.io;
const mem = std.mem;
const process = std.process;

const clap = @import("clap");
