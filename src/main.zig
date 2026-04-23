const std = @import("std");

const Chameleon = @import("chameleon");
const clap = @import("clap");

const cli = @import("cli/cli.zig");

pub fn main(init: std.process.Init) !void {
    var iter = try init.minimal.args.iterateAllocator(init.gpa);
    defer iter.deinit();

    _ = iter.next();

    var diag = clap.Diagnostic{};
    var res: cli.main.Args = clap.parseEx(clap.Help, &cli.main.params, clap.parsers.default, &iter, .{
        .diagnostic = &diag,
        .allocator = init.gpa,
        .terminating_positional = 0,
    }) catch |err| {
        try diag.reportToFile(init.io, .stderr(), err);
        return err;
    };
    defer res.deinit();

    var c = Chameleon.initRuntimeFromEnviron(.{ .allocator = init.gpa }, init.environ_map);
    defer c.deinit();

    var stderr = std.Io.File.stderr().writer(init.io, &.{});

    if (res.positionals[0]) |maybe_command| {
        if (std.meta.stringToEnum(cli.main.Command, maybe_command)) |command| {
            switch (command) {
                .help => {
                    defer std.process.exit(0);
                    try cli.help.invoke(init.io, init.gpa, init.environ_map, &c, &stderr.interface, &iter);
                },
                .alias => {
                    defer std.process.exit(0);
                    try cli.alias.invoke(init.io, init.gpa, init.environ_map, &c, &stderr.interface, &iter);
                },
            }
        }
    }

    try cli.main.invoke(init.io, init.gpa, init.environ_map, &c, &stderr.interface, &iter, &res);
}

test {
    _ = @import("cli/cli.zig");
}
