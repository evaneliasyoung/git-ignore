const std = @import("std");

const Chameleon = @import("chameleon");

fn printWithPrefix(
    io: std.Io,
    c: *Chameleon.RuntimeChameleon,
    prefix: []const u8,
    comptime format: []const u8,
    args: anytype,
) !void {
    var buf: [1024]u8 = undefined;
    var writer = std.Io.File.stderr().writer(io, &buf);
    try c.print(&writer.interface, "{s}: ", .{prefix});
    try writer.interface.print(format, args);
    try writer.interface.flush();
}

pub fn info(io: std.Io, c: *Chameleon.RuntimeChameleon, comptime format: []const u8, args: anytype) !void {
    try printWithPrefix(io, c.bold().green(), "info", format, args);
}

pub fn warn(io: std.Io, c: *Chameleon.RuntimeChameleon, comptime format: []const u8, args: anytype) !void {
    try printWithPrefix(io, c.bold().yellow(), "warn", format, args);
}

pub fn err(io: std.Io, c: *Chameleon.RuntimeChameleon, comptime format: []const u8, args: anytype) !void {
    try printWithPrefix(io, c.bold().red(), "error", format, args);
}
