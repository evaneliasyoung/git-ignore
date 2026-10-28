const std = @import("std");

const cli = @import("cli.zig");
const lib = @import("git_ignore");

pub fn invoke(
    _: std.Io,
    _: std.mem.Allocator,
    _: *std.process.Environ.Map,
    t: *const std.Io.Terminal,
    _: *std.Io.Writer,
    iter: *std.process.Args.Iterator,
) !void {
    if (iter.next()) |maybe_help_subject| {
        if (std.meta.stringToEnum(cli.main.Command, maybe_help_subject)) |help_subject| {
            switch (help_subject) {
                .help => {},
                .alias => return try cli.help.alias(t),
            }
        }
    }

    return try cli.help.main(t);
}

pub fn main(t: *const std.Io.Terminal) !void {
    // Header
    try t.setColor(.bold);
    try t.setColor(.yellow);
    try t.writer.writeAll("git-ignore");
    try t.setColor(.reset);
    try t.writer.writeAll(" is a tool to generate .gitignore files from www.gitignore.io. ");
    try t.setColor(.dim);
    try t.writer.print("({s})\n\n", .{lib.version});
    try t.setColor(.reset);

    // Usage
    try t.setColor(.bold);
    try t.writer.writeAll("Usage: git ignore ");
    try t.setColor(.cyan);
    try t.writer.writeAll("[...flags]");
    try t.setColor(.reset);
    try t.setColor(.bold);
    try t.writer.writeAll(" [command] ");
    try t.setColor(.cyan);
    try t.writer.writeAll("[...flags]");
    try t.setColor(.reset);
    try t.setColor(.bold);
    try t.writer.writeAll(" [...args]\n\n");
    try t.setColor(.reset);

    // Commands
    try t.setColor(.bold);
    try t.writer.writeAll("Commands:\n");
    try t.setColor(.reset);

    try t.writer.writeAll("  ");
    try t.setColor(.bold);
    try t.setColor(.magenta);
    try t.writer.writeAll("alias");
    try t.setColor(.reset);
    try t.setColor(.dim);
    try t.writer.writeAll("              ");
    try t.setColor(.reset);
    try t.writer.writeAll("Manage ignore aliases\n");

    try t.writer.writeAll("  ");
    try t.setColor(.bold);
    try t.setColor(.cyan);
    try t.writer.writeAll("help");
    try t.setColor(.reset);
    try t.setColor(.dim);
    try t.writer.writeAll("  [<command>]  ");
    try t.setColor(.reset);
    try t.writer.writeAll("Print help text and exit\n");

    try t.writer.writeByte('\n');

    // Flags
    try t.setColor(.bold);
    try t.writer.writeAll("Flags:\n");
    try t.setColor(.reset);

    try t.setColor(.cyan);
    try t.writer.writeAll("  -l");
    try t.setColor(.reset);
    try t.writer.writeAll(", ");
    try t.setColor(.cyan);
    try t.writer.writeAll("--list");
    try t.setColor(.reset);
    try t.writer.writeAll("         List templates\n");

    try t.setColor(.cyan);
    try t.writer.writeAll("  -u");
    try t.setColor(.reset);
    try t.writer.writeAll(", ");
    try t.setColor(.cyan);
    try t.writer.writeAll("--update");
    try t.setColor(.reset);
    try t.writer.writeAll("       Update all templates by fetching them from gitignore.io\n");

    try t.setColor(.cyan);
    try t.writer.writeAll("  -w");
    try t.setColor(.reset);
    try t.writer.writeAll(", ");
    try t.setColor(.cyan);
    try t.writer.writeAll("--write");
    try t.setColor(.reset);
    try t.writer.writeAll("        Write to .gitignore file instead of stdout\n");

    try t.setColor(.cyan);
    try t.writer.writeAll("  -f");
    try t.setColor(.reset);
    try t.writer.writeAll(", ");
    try t.setColor(.cyan);
    try t.writer.writeAll("--force");
    try t.setColor(.reset);
    try t.writer.writeAll("        Forcefully overwrite existing .gitignore file\n");

    try t.setColor(.cyan);
    try t.writer.writeAll("  -v");
    try t.setColor(.reset);
    try t.writer.writeAll(", ");
    try t.setColor(.cyan);
    try t.writer.writeAll("--version");
    try t.setColor(.reset);
    try t.writer.writeAll("      Display version information and exit\n");
}

pub fn alias(t: *const std.Io.Terminal) !void {
    // Usage
    try t.setColor(.bold);
    try t.writer.writeAll("Usage: ");
    try t.setColor(.green);
    try t.writer.writeAll("git ignore alias ");
    try t.setColor(.reset);
    try t.setColor(.cyan);
    try t.writer.writeAll("<flag> ");
    try t.setColor(.reset);
    try t.setColor(.blue);
    try t.writer.writeAll("[alias] ");
    try t.setColor(.reset);
    try t.setColor(.magenta);
    try t.writer.writeAll("[...templates]\n");
    try t.setColor(.reset);

    // Flags
    try t.setColor(.bold);
    try t.writer.writeAll("Flags:\n");
    try t.setColor(.reset);

    try t.setColor(.cyan);
    try t.writer.writeAll("  -l");
    try t.setColor(.reset);
    try t.writer.writeAll(", ");
    try t.setColor(.cyan);
    try t.writer.writeAll("--list");
    try t.setColor(.reset);
    try t.writer.writeAll("         List aliases\n");

    try t.setColor(.cyan);
    try t.writer.writeAll("  -a");
    try t.setColor(.reset);
    try t.writer.writeAll(", ");
    try t.setColor(.cyan);
    try t.writer.writeAll("--add");
    try t.setColor(.reset);
    try t.writer.writeAll("          Add an alias\n");

    try t.setColor(.cyan);
    try t.writer.writeAll("  -r");
    try t.setColor(.reset);
    try t.writer.writeAll(", ");
    try t.setColor(.cyan);
    try t.writer.writeAll("--remove");
    try t.setColor(.reset);
    try t.writer.writeAll("       Remove an alias\n");

    try t.writer.writeByte('\n');

    // Examples
    try t.setColor(.bold);
    try t.writer.writeAll("Examples:\n");
    try t.setColor(.reset);

    try t.setColor(.dim);
    try t.writer.writeAll("  List all aliases\n");
    try t.setColor(.reset);

    try t.setColor(.green);
    try t.writer.writeAll("  git ignore alias ");
    try t.setColor(.reset);
    try t.setColor(.cyan);
    try t.writer.writeAll("-l\n\n");
    try t.setColor(.reset);

    try t.setColor(.dim);
    try t.writer.writeAll("  Create or update the node alias\n");
    try t.setColor(.reset);

    try t.setColor(.bold);
    try t.setColor(.green);
    try t.writer.writeAll("  git ignore alias ");
    try t.setColor(.reset);
    try t.setColor(.cyan);
    try t.writer.writeAll("-a ");
    try t.setColor(.reset);
    try t.setColor(.blue);
    try t.writer.writeAll("node ");
    try t.setColor(.reset);
    try t.setColor(.magenta);
    try t.writer.writeAll("node svelte visualstudiocode\n\n");
    try t.setColor(.reset);

    try t.setColor(.dim);
    try t.writer.writeAll("  Remove the node alias\n");
    try t.setColor(.reset);

    try t.setColor(.green);
    try t.writer.writeAll("  git ignore alias ");
    try t.setColor(.reset);
    try t.setColor(.cyan);
    try t.writer.writeAll("-r ");
    try t.setColor(.reset);
    try t.setColor(.blue);
    try t.writer.writeAll("node\n");
    try t.setColor(.reset);
}
