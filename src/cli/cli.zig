const std = @import("std");

pub const fs = @import("fs.zig");
pub const print = @import("print.zig");

pub const alias = @import("alias.zig");
pub const help = @import("help.zig");
pub const main = @import("main.zig");

pub const ExitCode = enum(u8) {
    OK = 0,
    Error = 1,
    Misuse = 2,
};

pub fn exitWithCode(code: ExitCode) noreturn {
    std.process.exit(@intFromEnum(code));
}

test {
    _ = @import("fs.zig");
    _ = @import("print.zig");

    _ = @import("alias.zig");
    _ = @import("help.zig");
    _ = @import("main.zig");
}
