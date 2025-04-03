pub const IgnoreFiles = @This();

pub const ParseError = json.ParseError(json.Scanner);

pub const empty: IgnoreFiles = .{ .map = .empty };

pub const HashMapType = std.StringHashMapUnmanaged(IgnoreFile);
pub const Iterator = HashMapType.Iterator;
pub const KeyIterator = HashMapType.KeyIterator;

map: HashMapType,

pub fn put(
    self: *IgnoreFiles,
    gpa: mem.Allocator,
    name: []const u8,
    ignore_file: IgnoreFile,
) mem.Allocator.Error!void {
    try self.map.put(gpa, name, ignore_file);
}

pub fn contains(self: *const IgnoreFiles, name: []const u8) bool {
    return self.map.contains(name);
}

pub fn get(self: *const IgnoreFiles, name: []const u8) ?IgnoreFile {
    return self.map.get(name);
}

pub fn iterator(self: *const IgnoreFiles) Iterator {
    return self.map.iterator();
}

pub fn keyIterator(self: *const IgnoreFiles) KeyIterator {
    return self.map.keyIterator();
}

fn convertFileNameToSnakeCase(gpa: mem.Allocator, s: []const u8) mem.Allocator.Error![]u8 {
    return try mem.replaceOwned(u8, gpa, s, "fileName", "file_name");
}

fn cloneFromJSON(
    gpa: mem.Allocator,
    parsed: *const json.Parsed(json.ArrayHashMap(IgnoreFile)),
) mem.Allocator.Error!IgnoreFiles {
    var result: IgnoreFiles = .empty;

    var it = parsed.value.map.iterator();
    while (it.next()) |entry| {
        const name = try gpa.alloc(u8, entry.key_ptr.*.len);
        mem.copyForwards(u8, name, entry.key_ptr.*);
        const copy = try entry.value_ptr.*.clone(gpa);

        try result.put(gpa, name, copy);
    }

    return result;
}

pub fn parseFromSlice(
    gpa: mem.Allocator,
    s: []const u8,
) (ParseError || mem.Allocator.Error)!IgnoreFiles {
    const replaced = try convertFileNameToSnakeCase(gpa, s);
    defer gpa.free(replaced);

    const parsed = try json.parseFromSlice(json.ArrayHashMap(IgnoreFile), gpa, replaced, .{});
    defer parsed.deinit();

    return try IgnoreFiles.cloneFromJSON(gpa, &parsed);
}

pub fn parseFromReader(gpa: mem.Allocator, reader: anytype) !IgnoreFiles {
    const alignment: u29 = @alignOf(u8);
    var array_list = try std.ArrayListAligned(u8, alignment).initCapacity(gpa, 1024);
    defer array_list.deinit();

    const max_size: usize = comptime 3 << 20; // 3MB
    reader.readAllArrayListAligned(alignment, &array_list, max_size) catch |err| switch (err) {
        error.StreamTooLong => return error.FileTooBig,
        else => |e| return e,
    };
    const data = try array_list.toOwnedSlice();
    defer gpa.free(data);

    return try parseFromSlice(gpa, data);
}

pub fn deinit(self: *IgnoreFiles, gpa: mem.Allocator) void {
    var it = self.iterator();
    while (it.next()) |entry| {
        gpa.free(entry.key_ptr.*);
        entry.value_ptr.*.deinit(gpa);
    }
    self.map.deinit(gpa);
}

test "convertFileNameToSnakeCase" {
    const gpa = testing.allocator;
    const data =
        \\{
        \\  "zig": {
        \\    "name": "zig",
        \\    "contents": "\n### zig ###\n",
        \\    "fileName": "zig.gitignore",
        \\    "key": "zig"
        \\  }
        \\}
    ;
    const replaced = try mem.replaceOwned(u8, gpa, data, "fileName", "file_name");
    defer gpa.free(replaced);

    try testing.expectEqual(null, mem.indexOf(u8, data, "file_name"));
    try testing.expectEqual(null, mem.indexOf(u8, replaced, "fileName"));
}

test "clonefromJSON" {
    const gpa = testing.allocator;
    const data =
        \\{
        \\  "zig": {
        \\    "name": "zig",
        \\    "contents": "\n### zig ###\n",
        \\    "fileName": "zig.gitignore",
        \\    "key": "zig"
        \\  }
        \\}
    ;
    const replaced = try convertFileNameToSnakeCase(gpa, data);
    defer gpa.free(replaced);

    const parsed = try json.parseFromSlice(json.ArrayHashMap(IgnoreFile), gpa, replaced, .{});
    defer parsed.deinit();

    var ignore_files = try IgnoreFiles.cloneFromJSON(gpa, &parsed);
    defer ignore_files.deinit(gpa);

    try testing.expectEqual(1, ignore_files.map.size);
    try testing.expect(ignore_files.contains("zig"));

    const zig_ignore = try (ignore_files.get("zig") orelse error.KeyNotFound);
    try testing.expectEqualSlices(u8, "zig", zig_ignore.name);
    try testing.expectEqualSlices(u8, "\n### zig ###\n", zig_ignore.contents);
    try testing.expectEqualSlices(u8, "zig.gitignore", zig_ignore.file_name);
    try testing.expectEqualSlices(u8, "zig", zig_ignore.key);
}

test "parseFromSlice" {
    const gpa = testing.allocator;
    const data =
        \\{
        \\  "zig": {
        \\    "name": "zig",
        \\    "contents": "\n### zig ###\n",
        \\    "fileName": "zig.gitignore",
        \\    "key": "zig"
        \\  }
        \\}
    ;
    var ignore_files = try IgnoreFiles.parseFromSlice(gpa, data);
    defer ignore_files.deinit(gpa);

    try testing.expectEqual(1, ignore_files.map.size);
    try testing.expect(ignore_files.contains("zig"));

    const zig_ignore = try (ignore_files.get("zig") orelse error.KeyNotFound);
    try testing.expectEqualSlices(u8, "zig", zig_ignore.name);
    try testing.expectEqualSlices(u8, "\n### zig ###\n", zig_ignore.contents);
    try testing.expectEqualSlices(u8, "zig.gitignore", zig_ignore.file_name);
    try testing.expectEqualSlices(u8, "zig", zig_ignore.key);
}

const std = @import("std");
const fs = std.fs;
const io = std.io;
const json = std.json;
const mem = std.mem;
const testing = std.testing;

const IgnoreFile = @import("ignore_file.zig");
