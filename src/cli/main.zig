pub const params = clap.parseParamsComptime(
    \\-l, --list     List templates
    \\-u, --update   Update all templates by fetching them from gitignore.io
    \\-w, --write    Write to .gitignore file instead of stdout
    \\-f, --force    Forcefully overwrite existing .gitignore file
    \\-v, --version  Display version information
    \\<string>
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
};

const ResultEx = clap.ResultEx(clap.Help, &params, clap.parsers.default);

const clap = @import("clap");
