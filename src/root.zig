const std = @import("std");
const testing = std.testing;

pub const version = @import("build").version;

pub const IgnoreFile = @import("lib/ignore_file.zig");
pub const IgnoreFiles = @import("lib/ignore_files.zig");
pub const IgnoreSite = @import("lib/ignore_site.zig");
pub const utils = @import("lib/utils.zig");

test {
    _ = @import("lib/ignore_file.zig");
    _ = @import("lib/ignore_files.zig");
    _ = @import("lib/ignore_site.zig");
    _ = @import("lib/utils.zig");
}
