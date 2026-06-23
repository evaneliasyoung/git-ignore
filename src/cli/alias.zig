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

pub fn invoke(
    io: std.Io,
    gpa: std.mem.Allocator,
    environ: *std.process.Environ.Map,
    c: *Chameleon.RuntimeChameleon,
    writer: *std.Io.Writer,
    iter: *std.process.Args.Iterator,
) !void {
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
        try diag.reportToFile(io, .stderr(), err);
        return err;
    };
    defer res.deinit();

    {
        const set_flags = @intFromBool(res.args.list != 0) +
            @intFromBool(res.args.add != 0) + @intFromBool(res.args.remove != 0);

        if (set_flags == 0) {
            defer std.process.exit(0);
            try cli.help.alias(c, writer);
        } else if (set_flags != 1) {
            defer std.process.exit(2);
            try cli.print.err(io, c, "You may only specify one of '-l', '-a', or '-r'.", .{});
        }
    }

    const alias = res.positionals[0];

    const templates = templates_are: {
        var templates: std.ArrayList([]const u8) = .empty;
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
            try cli.print.err(io, c, "Must supply an alias to create\n", .{});
        } else if (templates.len == 0) {
            defer std.process.exit(2);
            try cli.print.err(io, c, "Must supply at least one template for an alias\n", .{});
        }
    } else if (res.args.remove != 0) {
        if (alias == null) {
            defer std.process.exit(2);
            try cli.print.err(io, c, "Must supply an alias to remove\n", .{});
        }
    }

    const aliases_path = try cli.fs.getAliasesPath(io, gpa, environ, null);
    defer gpa.free(aliases_path);

    var ignore_aliases: lib.IgnoreAliases = ignore_aliases_are: {
        if (cli.fs.existsAbsolute(io, aliases_path)) {
            const file = try std.Io.Dir.openFileAbsolute(io, aliases_path, .{ .mode = .read_only });
            defer file.close(io);
            break :ignore_aliases_are lib.IgnoreAliases.parseFromFile(io, gpa, file);
        } else {
            try cli.print.warn(io, c, "Cache directory or templates file not found, creating...\n", .{});
            break :ignore_aliases_are lib.IgnoreAliases.empty;
        }
    } catch |err| {
        defer std.process.exit(1);
        try cli.print.err(io, c, "{any}\n", .{err});
    };
    defer ignore_aliases.deinit(gpa);

    if (res.args.list != 0) {
        defer std.process.exit(0);
        try ignore_aliases.writeAliases(gpa, writer);
    }

    const file = try std.Io.Dir.createFileAbsolute(io, aliases_path, .{});
    defer file.close(io);
    var file_writer = file.writer(io, &.{});

    if (res.args.add != 0) {
        try ignore_aliases.put(gpa, alias orelse unreachable, templates);
        const joined = try std.mem.join(gpa, ", ", templates);

        try ignore_aliases.writeSerialized(gpa, &file_writer.interface);
        try cli.print.info(io, c, "Added alias '{s}' of [{s}]\n", .{ alias orelse unreachable, joined });
    } else if (res.args.remove != 0) {
        if (!ignore_aliases.remove(alias orelse unreachable)) {
            defer std.process.exit(0);
            try cli.print.warn(io, c, "Couldn't find alias '{s}' to remove\n", .{alias orelse unreachable});
        }

        try ignore_aliases.writeSerialized(gpa, &file_writer.interface);
        try cli.print.info(io, c, "Removed alias '{s}'\n", .{alias orelse unreachable});
    }
}
