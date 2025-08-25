const std = @import("std");

const Chameleon = @import("chameleon");
const clap = @import("clap");

const cli = @import("cli.zig");
const lib = @import("git_ignore");

pub const params = clap.parseParamsComptime(
    \\-l, --list    List aliases
    \\-a, --add     Add an alias
    \\-r, --remove  Remove an alias
    \\<string>      Alias and (optionally) templates
    \\
);

pub const Args = clap.ResultEx(clap.Help, &cli.alias.params, clap.parsers.default);

pub fn invoke(gpa: std.mem.Allocator, iter: *std.process.ArgIterator) !void {
    var diag = clap.Diagnostic{};
    var res: cli.alias.Args = clap.parseEx(
        clap.Help,
        &cli.alias.params,
        clap.parsers.default,
        iter,
        .{
            .diagnostic = &diag,
            .allocator = gpa,
            .terminating_positional = 0,
        },
    ) catch |err| {
        try diag.reportToFile(.stderr(), err);
        return err;
    };
    defer res.deinit();

    var c = Chameleon.initRuntime(.{ .allocator = gpa });
    defer c.deinit();

    {
        const set_flags = @intFromBool(res.args.list != 0) +
            @intFromBool(res.args.add != 0) + @intFromBool(res.args.remove != 0);

        if (set_flags == 0) {
            defer std.process.exit(0);
            try cli.help.alias(gpa, std.io.getStdErr().writer());
        } else if (set_flags != 1) {
            defer std.process.exit(2);
            try cli.print.err(&c, "You may only specify one of '-l', '-a', or '-r'.", .{});
        }
    }

    const alias = res.positionals[0];

    const templates = templates_are: {
        var templates: std.ArrayListUnmanaged([]const u8) = .empty;
        defer templates.deinit(gpa);

        while (iter.next()) |template| {
            try templates.append(gpa, template);
        }

        break :templates_are try templates.toOwnedSlice(gpa);
    };
    defer gpa.free(templates);

    if (res.args.add != 0) {
        if (alias == null) {
            defer std.process.exit(2);
            try cli.print.err(&c, "Must supply an alias to create\n", .{});
        } else if (templates.len == 0) {
            defer std.process.exit(2);
            try cli.print.err(&c, "Must supply at least one template for an alias\n", .{});
        }
    } else if (res.args.remove != 0) {
        if (alias == null) {
            defer std.process.exit(2);
            try cli.print.err(&c, "Must supply an alias to remove\n", .{});
        }
    }

    const aliases_path = try cli.fs.getAliasesPath(gpa, null);
    defer gpa.free(aliases_path);

    var ignore_aliases: lib.IgnoreAliases = ignore_aliases_are: {
        if (cli.fs.existsAbsolute(aliases_path)) {
            const file = try std.fs.openFileAbsolute(aliases_path, .{ .mode = .read_only });
            defer file.close();
            break :ignore_aliases_are lib.IgnoreAliases.parseFromReader(gpa, file.reader());
        } else {
            try cli.print.warn(&c, "Cache directory or templates file not found, creating...\n", .{});
            break :ignore_aliases_are lib.IgnoreAliases.empty;
        }
    } catch |err| {
        defer std.process.exit(1);
        try cli.print.err(&c, "{any}\n", .{err});
    };
    defer ignore_aliases.deinit(gpa);

    if (res.args.list != 0) {
        defer std.process.exit(0);
        try ignore_aliases.writeAliases(gpa, std.io.getStdErr().writer());
    }

    const file = try std.fs.createFileAbsolute(aliases_path, .{});
    defer file.close();

    if (res.args.add != 0) {
        try ignore_aliases.put(gpa, alias orelse unreachable, templates);
        const joined = try std.mem.join(gpa, ", ", templates);

        try ignore_aliases.writeSerialized(gpa, file.writer());
        try cli.print.info(&c, "Added alias '{s}' of [{s}]\n", .{ alias orelse unreachable, joined });
    } else if (res.args.remove != 0) {
        if (!ignore_aliases.remove(alias orelse unreachable)) {
            defer std.process.exit(0);
            try cli.print.warn(&c, "Couldn't find alias '{s}' to remove\n", .{alias orelse unreachable});
        }

        try ignore_aliases.writeSerialized(gpa, file.writer());
        try cli.print.info(&c, "Removed alias '{s}'\n", .{alias orelse unreachable});
    }
}
