const std = @import("std");

const IgnoreFile = @import("ignore_file.zig");
const utils = @import("utils.zig");

pub const IgnoreFiles = @This();

pub const ParseError = std.json.ParseError(std.json.Scanner);

pub const empty: IgnoreFiles = .{ .map = .empty };

pub const HashMapType = std.StringHashMapUnmanaged(IgnoreFile);
pub const Iterator = HashMapType.Iterator;
pub const KeyIterator = HashMapType.KeyIterator;

map: HashMapType,

pub fn put(
    self: *IgnoreFiles,
    gpa: std.mem.Allocator,
    name: []const u8,
    ignore_file: IgnoreFile,
) std.mem.Allocator.Error!void {
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

fn convertFileNameToSnakeCase(gpa: std.mem.Allocator, s: []const u8) std.mem.Allocator.Error![]u8 {
    return try std.mem.replaceOwned(u8, gpa, s, "fileName", "file_name");
}

fn cloneFromJSON(
    gpa: std.mem.Allocator,
    parsed: *const std.json.Parsed(std.json.ArrayHashMap(IgnoreFile)),
) std.mem.Allocator.Error!IgnoreFiles {
    var result: IgnoreFiles = .empty;

    var it = parsed.value.map.iterator();
    while (it.next()) |entry| {
        const name = try gpa.alloc(u8, entry.key_ptr.*.len);
        std.mem.copyForwards(u8, name, entry.key_ptr.*);
        const copy = try entry.value_ptr.*.clone(gpa);

        try result.put(gpa, name, copy);
    }

    return result;
}

pub fn parseFromSlice(
    gpa: std.mem.Allocator,
    s: []const u8,
) (ParseError || std.mem.Allocator.Error)!IgnoreFiles {
    const replaced = try convertFileNameToSnakeCase(gpa, s);
    defer gpa.free(replaced);

    const parsed = try std.json.parseFromSlice(std.json.ArrayHashMap(IgnoreFile), gpa, replaced, .{});
    defer parsed.deinit();

    return try IgnoreFiles.cloneFromJSON(gpa, &parsed);
}

pub fn parseFromFile(io: std.Io, gpa: std.mem.Allocator, file: std.Io.File) !IgnoreFiles {
    var buf: [1024]u8 = undefined;
    var reader = file.reader(io, &buf);

    return try parseFromReader(gpa, &reader.interface);
}

pub fn parseFromReader(gpa: std.mem.Allocator, reader: *std.Io.Reader) !IgnoreFiles {
    const max_size: usize = comptime 3 << 20; // 3MB
    const data = try reader.allocRemaining(gpa, .limited(max_size));
    defer gpa.free(data);

    return try parseFromSlice(gpa, data);
}

pub fn deinit(self: *IgnoreFiles, gpa: std.mem.Allocator) void {
    var it = self.iterator();
    while (it.next()) |entry| {
        gpa.free(entry.key_ptr.*);
        entry.value_ptr.*.deinit(gpa);
    }
    self.map.deinit(gpa);
}

pub fn writeTemplateNames(
    self: *const IgnoreFiles,
    gpa: std.mem.Allocator,
    writer: *std.Io.Writer,
    names: []const []const u8,
) !void {
    const template_names: [][]const u8 = blk: {
        var array_list: std.ArrayList([]const u8) = .empty;
        defer array_list.deinit(gpa);

        var it = self.keyIterator();
        while (it.next()) |template_name| {
            if (names.len != 0) {
                for (names) |name| {
                    if (std.mem.indexOf(u8, template_name.*, name) != null) {
                        try array_list.append(gpa, template_name.*);
                    }
                }
            } else {
                try array_list.append(gpa, template_name.*);
            }
        }

        break :blk try array_list.toOwnedSlice(gpa);
    };
    defer gpa.free(template_names);

    utils.sortStringSlice(template_names);

    for (template_names) |template_name| {
        try writer.print("{s}\n", .{template_name});
    }
}

pub fn writeTemplates(
    self: *const IgnoreFiles,
    gpa: std.mem.Allocator,
    writer: *std.Io.Writer,
    names: []const []const u8,
) !void {
    const template_names: [][]const u8 = filter: {
        var array_list: std.ArrayList([]const u8) = .empty;
        defer array_list.deinit(gpa);

        for (names) |name| {
            if (self.contains(name)) {
                try array_list.append(gpa, name);
            }
        }

        break :filter try array_list.toOwnedSlice(gpa);
    };
    defer gpa.free(template_names);

    utils.sortStringSlice(template_names);

    if (template_names.len != 0) {
        const joined = try std.mem.join(gpa, ",", template_names);
        defer gpa.free(joined);

        _ = try writer.print("# Created by https://gitignore.io/api/{s}\n", .{joined});
        _ = try writer.print("# Edit at https://gitignore.io/?templates={s}\n", .{joined});
        for (template_names) |template_name| {
            const ignore_file = self.get(template_name) orelse unreachable;
            _ = try writer.write(ignore_file.contents);
        }
        _ = try writer.print("\n# End of https://gitignore.io/api/{s}\n", .{joined});
    }
}

test "convertFileNameToSnakeCase" {
    const gpa = std.testing.allocator;
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
    const replaced = try std.mem.replaceOwned(u8, gpa, data, "fileName", "file_name");
    defer gpa.free(replaced);

    try std.testing.expectEqual(null, std.mem.indexOf(u8, data, "file_name"));
    try std.testing.expectEqual(null, std.mem.indexOf(u8, replaced, "fileName"));
}

test "clonefromJSON" {
    const gpa = std.testing.allocator;
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

    const parsed = try std.json.parseFromSlice(std.json.ArrayHashMap(IgnoreFile), gpa, replaced, .{});
    defer parsed.deinit();

    var ignore_files = try IgnoreFiles.cloneFromJSON(gpa, &parsed);
    defer ignore_files.deinit(gpa);

    try std.testing.expectEqual(1, ignore_files.map.size);
    try std.testing.expect(ignore_files.contains("zig"));

    const zig_ignore = try (ignore_files.get("zig") orelse error.KeyNotFound);
    try std.testing.expectEqualSlices(u8, "zig", zig_ignore.name);
    try std.testing.expectEqualSlices(u8, "\n### zig ###\n", zig_ignore.contents);
    try std.testing.expectEqualSlices(u8, "zig.gitignore", zig_ignore.file_name);
    try std.testing.expectEqualSlices(u8, "zig", zig_ignore.key);
}

test "parseFromSlice" {
    const gpa = std.testing.allocator;
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

    try std.testing.expectEqual(1, ignore_files.map.size);
    try std.testing.expect(ignore_files.contains("zig"));

    const zig_ignore = try (ignore_files.get("zig") orelse error.KeyNotFound);
    try std.testing.expectEqualSlices(u8, "zig", zig_ignore.name);
    try std.testing.expectEqualSlices(u8, "\n### zig ###\n", zig_ignore.contents);
    try std.testing.expectEqualSlices(u8, "zig.gitignore", zig_ignore.file_name);
    try std.testing.expectEqualSlices(u8, "zig", zig_ignore.key);
}
