const std = @import("std");

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

    var stderr = std.Io.File.stderr().writer(init.io, &.{});

    const noColor = init.environ_map.contains("NO_COLOR");
    const forceColor = init.environ_map.contains("CLICOLOR_FORCE");
    const t: std.Io.Terminal = .{
        .writer = &stderr.interface,
        .mode = try .detect(init.io, .stderr(), noColor, forceColor),
    };

    if (res.positionals[0]) |maybe_command| {
        if (std.meta.stringToEnum(cli.main.Command, maybe_command)) |command| {
            switch (command) {
                .help => {
                    defer cli.exitWithCode(.OK);
                    try cli.help.invoke(init.io, init.gpa, init.environ_map, &t, &stderr.interface, &iter);
                },
                .alias => {
                    defer cli.exitWithCode(.OK);
                    try cli.alias.invoke(init.io, init.gpa, init.environ_map, &t, &stderr.interface, &iter);
                },
            }
        }
    }

    try cli.main.invoke(init.io, init.gpa, init.environ_map, &t, &stderr.interface, &iter, &res);
}

test {
    _ = @import("cli/cli.zig");
}
