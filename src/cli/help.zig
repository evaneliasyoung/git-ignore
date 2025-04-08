pub fn invoke(gpa: mem.Allocator, iter: *process.ArgIterator) !void {
    _ = iter;
    try main(gpa, std.io.getStdErr().writer());
}

pub fn main(gpa: mem.Allocator, writer: anytype) !void {
    var c = Chameleon.initRuntime(.{ .allocator = gpa });
    defer c.deinit();

    var bold = try c.bold().createPreset();
    defer bold.deinit();

    var dim = try c.dim().createPreset();
    defer dim.deinit();

    var cyan = try c.bold().cyan().createPreset();
    defer cyan.deinit();

    var magenta = try c.bold().magenta().createPreset();
    defer magenta.deinit();

    // Header
    try c.bold().yellow().print(writer, "git-ignore", .{});
    _ = try writer.write(" is a tool to generate .gitignore files from www.gitignore.io. ");
    try dim.print(writer, "({s})\n\n", .{lib.version});

    // Usage
    try bold.print(writer, "Usage: git ignore ", .{});
    try cyan.print(writer, "[...flags]", .{});
    try bold.print(writer, " [command] ", .{});
    try cyan.print(writer, "[...flags]", .{});
    try bold.print(writer, " [...args]\n\n", .{});

    // Commands
    try bold.print(writer, "Commands:\n", .{});

    _ = try writer.write("  ");
    try magenta.print(writer, "alias", .{});
    _ = try writer.write("              ");
    _ = try writer.write("Manage ignore aliases\n");

    _ = try writer.write("  ");
    try cyan.print(writer, "help", .{});
    try dim.print(writer, "  [<command>]  ", .{});
    _ = try writer.write("Print help text and exit\n");
    _ = try writer.write("\n");

    // Flags
    try bold.print(writer, "Flags:\n", .{});

    try cyan.print(writer, "  -l", .{});
    _ = try writer.write(", ");
    try cyan.print(writer, "--list", .{});
    _ = try writer.write("         List templates\n");

    try cyan.print(writer, "  -u", .{});
    _ = try writer.write(", ");
    try cyan.print(writer, "--update", .{});
    _ = try writer.write("       Update all templates by fetching them from gitignore.io\n");

    try cyan.print(writer, "  -w", .{});
    _ = try writer.write(", ");
    try cyan.print(writer, "--write", .{});
    _ = try writer.write("        Write to .gitignore file instead of stdout\n");

    try cyan.print(writer, "  -f", .{});
    _ = try writer.write(", ");
    try cyan.print(writer, "--force", .{});
    _ = try writer.write("        Forcefully overwrite existing .gitignore file\n");

    try cyan.print(writer, "  -v", .{});
    _ = try writer.write(", ");
    try cyan.print(writer, "--version", .{});
    _ = try writer.write("      Display version information and exit\n");
}

pub fn alias(gpa: mem.Allocator, writer: anytype) !void {
    var c = Chameleon.initRuntime(.{ .allocator = gpa });
    defer c.deinit();

    _ = try writer.write("TODO\n");
}

const std = @import("std");
const builtin = @import("builtin");
const mem = std.mem;
const process = std.process;

const Chameleon = @import("chameleon");

const lib = @import("git_ignore_lib");
