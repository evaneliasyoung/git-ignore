pub const params = clap.parseParamsComptime(
    \\-l, --list     List templates
    \\-u, --update   Update all templates by fetching them from gitignore.io
    \\-w, --write    Write to .gitignore file instead of stdout
    \\-f, --force    Forcefully overwrite existing .gitignore file
    \\-v, --version  Display version information
    \\<string>       Command and/or templates
    \\
);

pub const SubCommands = enum {
    help,
};

pub const Arguments = struct {
    list: bool,
    update: bool,
    write: bool,
    force: bool,
    version: bool,

    pub fn init(result: *const ResultEx) Arguments {
        return .{
            .list = result.args.list != 0,
            .update = result.args.update != 0,
            .write = result.args.write != 0,
            .force = result.args.force != 0,
            .version = result.args.version != 0,
        };
    }

    pub fn isEmpty(self: *const Arguments) bool {
        return !(self.list or self.update or self.write or self.force or self.version);
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

const ResultEx = clap.ResultEx(clap.Help, &params, clap.parsers.default);

const clap = @import("clap");
