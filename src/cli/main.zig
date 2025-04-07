pub const ParseError = error{ ForceWithoutWrite, EmptyArguments };

pub const params = clap.parseParamsComptime(
    \\-l, --list     List templates
    \\-u, --update   Update all templates by fetching them from gitignore.io
    \\-w, --write    Write to .gitignore file instead of stdout
    \\-f, --force    Forcefully overwrite existing .gitignore file
    \\-v, --version  Display version information
    \\<string>       Command and/or templates
    \\
);

pub const Command = enum {
    help,
};

pub const Arguments = struct {
    list: bool,
    update: bool,
    write: bool,
    force: bool,
    version: u8,
    command: ?Command,
    templates: []const []const u8,

    pub fn init(gpa: mem.Allocator) !Arguments {
        var iter = try process.ArgIterator.initWithAllocator(gpa);
        _ = iter.next();

        defer iter.deinit();

        var diag = clap.Diagnostic{};
        var res = clap.parseEx(clap.Help, &params, clap.parsers.default, &iter, .{
            .diagnostic = &diag,
            .allocator = gpa,
            .terminating_positional = 0,
        }) catch |err| {
            diag.report(io.getStdErr().writer(), err) catch {};
            return err;
        };
        defer res.deinit();

        const flags: struct {
            list: bool,
            update: bool,
            write: bool,
            force: bool,
            version: u8,
        } = .{
            .list = res.args.list != 0,
            .update = res.args.update != 0,
            .write = res.args.write != 0,
            .force = res.args.force != 0,
            .version = res.args.version,
        };

        const positionals: struct {
            command: ?Command,
            templates: [][]const u8,
        } = gather: {
            var templates: std.ArrayListUnmanaged([]const u8) = .empty;
            defer templates.deinit(gpa);

            var command: ?Command = null;
            if (res.positionals[0]) |maybe_command| {
                if (meta.stringToEnum(Command, maybe_command)) |as_command| {
                    command = as_command;
                } else {
                    const template_copy = try gpa.alloc(u8, maybe_command.len);
                    mem.copyForwards(u8, template_copy, maybe_command);
                    try templates.append(gpa, template_copy);
                }
            }
            while (iter.next()) |template| {
                const template_copy = try gpa.alloc(u8, template.len);
                mem.copyForwards(u8, template_copy, template);
                try templates.append(gpa, template_copy);
            }

            break :gather .{
                .command = command,
                .templates = try templates.toOwnedSlice(gpa),
            };
        };

        if (flags.force and !flags.write) return ParseError.ForceWithoutWrite;
        if (!(flags.list or flags.update or flags.write or flags.force or flags.version != 0) and positionals.command == null and positionals.templates.len == 0) return ParseError.EmptyArguments;

        return .{
            .list = flags.list,
            .update = flags.update,
            .write = flags.write,
            .force = flags.force,
            .version = flags.version,
            .command = positionals.command,
            .templates = positionals.templates,
        };
    }

    pub fn deinit(self: *const Arguments, gpa: mem.Allocator) void {
        for (self.templates) |template| {
            gpa.free(template);
        }
        gpa.free(self.templates);
    }
};

pub fn help(writer: anytype) !void {
    _ = try writer.write("usage: git-ignore [flags] [command] [<args>]\n");
    try clap.help(
        writer,
        clap.Help,
        &params,
        .{
            .description_on_new_line = false,
            .indent = 2,
            .spacing_between_parameters = 0,
        },
    );
}

pub fn version(writer: anytype, args: *const Arguments) !void {
    switch (args.version) {
        1 => try writer.print("{s}\n", .{lib.version}),
        2 => try writer.print(
            \\Target: {s}-{s}
            \\git-ignore version {s}
        , .{
            @tagName(builtin.target.os.tag),
            @tagName(builtin.target.cpu.arch),
            lib.version,
        }),
        else => try writer.print(
            \\Target: {s}-{s}
            \\Mode: {s}
            \\git-ignore version {s}
        , .{
            @tagName(builtin.target.os.tag),
            @tagName(builtin.target.cpu.arch),
            @tagName(builtin.mode),
            lib.version,
        }),
    }
}

const ResultEx = clap.ResultEx(clap.Help, &params, clap.parsers.default);

const std = @import("std");
const builtin = @import("builtin");
const io = std.io;
const mem = std.mem;
const meta = std.meta;
const process = std.process;

const clap = @import("clap");

const lib = @import("git_ignore_lib");
