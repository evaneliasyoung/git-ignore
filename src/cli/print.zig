const std = @import("std");
const io = std.io;

const Chameleon = @import("chameleon");

fn printWithPrefix(
    c: *Chameleon.RuntimeChameleon,
    prefix: []const u8,
    comptime format: []const u8,
    args: anytype,
) !void {
    const writer = io.getStdErr().writer();
    try c.print(writer, "{s}: ", .{prefix});
    try writer.print(format, args);
}

pub fn info(c: *Chameleon.RuntimeChameleon, comptime format: []const u8, args: anytype) !void {
    try printWithPrefix(c.bold().green(), "info", format, args);
}

pub fn warn(c: *Chameleon.RuntimeChameleon, comptime format: []const u8, args: anytype) !void {
    try printWithPrefix(c.bold().yellow(), "warn", format, args);
}

pub fn err(c: *Chameleon.RuntimeChameleon, comptime format: []const u8, args: anytype) !void {
    try printWithPrefix(c.bold().red(), "error", format, args);
}
