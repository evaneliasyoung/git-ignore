pub const IgnoreFile = @This();

name: []u8,
contents: []u8,
file_name: []u8,
key: []u8,

pub fn init(
    gpa: Allocator,
    name: []const u8,
    contents: []const u8,
    file_name: []const u8,
    key: []const u8,
) mem.Allocator.Error!IgnoreFile {
    const name_copy = try gpa.alloc(u8, name.len);
    const contents_copy = try gpa.alloc(u8, contents.len);
    const file_name_copy = try gpa.alloc(u8, file_name.len);
    const key_copy = try gpa.alloc(u8, key.len);

    mem.copyForwards(u8, name_copy, name);
    mem.copyForwards(u8, contents_copy, contents);
    mem.copyForwards(u8, file_name_copy, file_name);
    mem.copyForwards(u8, key_copy, key);

    return .{
        .name = name_copy,
        .contents = contents_copy,
        .file_name = file_name_copy,
        .key = key_copy,
    };
}

pub fn clone(self: *const IgnoreFile, gpa: Allocator) mem.Allocator.Error!IgnoreFile {
    return try IgnoreFile.init(gpa, self.name, self.contents, self.file_name, self.key);
}

pub fn deinit(self: *IgnoreFile, gpa: Allocator) void {
    gpa.free(self.name);
    gpa.free(self.contents);
    gpa.free(self.file_name);
    gpa.free(self.key);
}

test "init" {
    const gpa = testing.allocator;

    var source = try IgnoreFile.init(gpa, "zig", "\n### zig ###\n", "zig.gitignore", "zig");
    defer source.deinit(gpa);

    try testing.expectEqualSlices(u8, "zig", source.name);
    try testing.expectEqualSlices(u8, "\n### zig ###\n", source.contents);
    try testing.expectEqualSlices(u8, "zig.gitignore", source.file_name);
    try testing.expectEqualSlices(u8, "zig", source.key);
}

test "clone" {
    const gpa = testing.allocator;

    var source = try IgnoreFile.init(gpa, "zig", "\n### zig ###\n", "zig.gitignore", "zig");
    defer source.deinit(gpa);

    var cloned = try source.clone(gpa);
    defer cloned.deinit(gpa);

    try testing.expectEqualSlices(u8, source.name, cloned.name);
    try testing.expectEqualSlices(u8, source.contents, cloned.contents);
    try testing.expectEqualSlices(u8, source.file_name, cloned.file_name);
    try testing.expectEqualSlices(u8, source.key, cloned.key);
}

const std = @import("std");
const json = std.json;
const mem = std.mem;
const testing = std.testing;

const Allocator = mem.Allocator;
