const std = @import("std");
const builtin = @import("builtin");
const io = std.io;
const mem = std.mem;
const meta = std.meta;
const process = std.process;

const Chameleon = @import("chameleon");

const cli = @import("cli.zig");
const lib = @import("git_ignore_lib");

pub fn invoke(gpa: mem.Allocator, iter: *process.ArgIterator) !void {
    const writer = io.getStdErr().writer();
    if (iter.next()) |maybe_help_subject| {
        if (meta.stringToEnum(cli.main.Command, maybe_help_subject)) |help_subject| {
            switch (help_subject) {
                .help => {},
                .alias => return try cli.help.alias(gpa, writer),
            }
        }
    }

    try cli.help.main(gpa, writer);
}

pub fn main(gpa: mem.Allocator, writer: anytype) !void {
    var c = Chameleon.initRuntime(.{ .allocator = gpa });
    defer c.deinit();

    var bold = try c.bold().createPreset();
    defer bold.deinit();

    var dim = try c.dim().createPreset();
    defer dim.deinit();

    var bold_cyan = try c.bold().cyan().createPreset();
    defer bold_cyan.deinit();

    var cyan = try c.cyan().createPreset();
    defer cyan.deinit();

    var bold_magenta = try c.bold().magenta().createPreset();
    defer bold_magenta.deinit();

    // Header
    try c.bold().yellow().print(writer, "git-ignore", .{});
    _ = try writer.write(" is a tool to generate .gitignore files from www.gitignore.io. ");
    try dim.print(writer, "({s})\n\n", .{lib.version});

    // Usage
    try bold.print(writer, "Usage: git ignore ", .{});
    try bold_cyan.print(writer, "[...flags]", .{});
    try bold.print(writer, " [command] ", .{});
    try bold_cyan.print(writer, "[...flags]", .{});
    try bold.print(writer, " [...args]\n\n", .{});

    // Commands
    try bold.print(writer, "Commands:\n", .{});

    _ = try writer.write("  ");
    try bold_magenta.print(writer, "alias", .{});
    _ = try writer.write("              ");
    _ = try writer.write("Manage ignore aliases\n");

    _ = try writer.write("  ");
    try bold_cyan.print(writer, "help", .{});
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

    var bold = try c.bold().createPreset();
    defer bold.deinit();

    var dim = try c.dim().createPreset();
    defer dim.deinit();

    var bold_green = try c.bold().green().createPreset();
    defer bold_green.deinit();

    var cyan = try c.cyan().createPreset();
    defer cyan.deinit();

    var blue = try c.blue().createPreset();
    defer blue.deinit();

    var magenta = try c.magenta().createPreset();
    defer magenta.deinit();

    _ = try writer.write("\n");

    // Usage
    try bold.print(writer, "Usage: ", .{});
    try bold_green.print(writer, "git ignore alias ", .{});
    try cyan.print(writer, "<flag> ", .{});
    try blue.print(writer, "[alias] ", .{});
    try magenta.print(writer, "[...templates]\n", .{});
    _ = try writer.write("  Create, update, or remove .gitignore template combinations or shorthand\n\n");

    // Flags
    try bold.print(writer, "Flags:\n", .{});

    try cyan.print(writer, "  -l", .{});
    _ = try writer.write(", ");
    try cyan.print(writer, "--list", .{});
    _ = try writer.write("         List aliases\n");

    try cyan.print(writer, "  -a", .{});
    _ = try writer.write(", ");
    try cyan.print(writer, "--add", .{});
    _ = try writer.write("          Add an alias\n");

    try cyan.print(writer, "  -r", .{});
    _ = try writer.write(", ");
    try cyan.print(writer, "--remove", .{});
    _ = try writer.write("       Remove an alias\n");

    _ = try writer.write("\n");

    // Examples
    try bold.print(writer, "Examples:\n", .{});

    try dim.print(writer, "  List all aliases\n", .{});
    try bold_green.print(writer, "  git ignore ", .{});
    try cyan.print(writer, "-l\n\n", .{});

    try dim.print(writer, "  Create or update the node alias\n", .{});
    try bold_green.print(writer, "  git ignore ", .{});
    try cyan.print(writer, "-a ", .{});
    try blue.print(writer, "node ", .{});
    try magenta.print(writer, "node svelte visualstudiocode\n\n", .{});

    try dim.print(writer, "  Remove the node alias\n", .{});
    try bold_green.print(writer, "  git ignore ", .{});
    try cyan.print(writer, "-r ", .{});
    try blue.print(writer, "node\n", .{});
}
