const std = @import("std");

fn printWithPrefix(
    t: *const std.Io.Terminal,
    color: std.Io.Terminal.Color,
    prefix: []const u8,
    comptime fmt: []const u8,
    args: anytype,
) !void {
    try t.setColor(.bold);
    try t.setColor(color);
    try t.writer.writeAll(prefix);
    try t.writer.writeAll(": ");
    try t.setColor(.reset);
    try t.writer.print(fmt, args);
}

pub fn info(t: *const std.Io.Terminal, comptime fmt: []const u8, args: anytype) !void {
    try printWithPrefix(t, .green, "info", fmt, args);
}

pub fn warn(t: *const std.Io.Terminal, comptime fmt: []const u8, args: anytype) !void {
    try printWithPrefix(t, .yellow, "warn", fmt, args);
}

pub fn err(t: *const std.Io.Terminal, comptime fmt: []const u8, args: anytype) !void {
    try printWithPrefix(t, .red, "error", fmt, args);
}
