pub const IgnoreAliases = @This();
pub const IgnoreAlias = []const []const u8;

pub const ParseError = json.ParseError(json.Scanner);

pub const empty: IgnoreAliases = .{ .map = .empty };

pub const HashMapType = std.StringHashMapUnmanaged(IgnoreAlias);
pub const Iterator = HashMapType.Iterator;
pub const KeyIterator = HashMapType.KeyIterator;

map: HashMapType,

pub fn put(
    self: *IgnoreAliases,
    gpa: mem.Allocator,
    name: []const u8,
    ignore_file: IgnoreAlias,
) mem.Allocator.Error!void {
    const name_copy = try gpa.alloc(u8, name.len);
    mem.copyForwards(u8, name_copy, name);
    const ignore_file_copy = ignore_file_is: {
        var array_list: std.ArrayListUnmanaged([]const u8) = .empty;
        defer array_list.deinit(gpa);

        for (ignore_file) |template| {
            const template_copy = try gpa.alloc(u8, template.len);
            mem.copyForwards(u8, template_copy, template);
            try array_list.append(gpa, template_copy);
        }

        break :ignore_file_is try array_list.toOwnedSlice(gpa);
    };

    try self.map.put(gpa, name_copy, ignore_file_copy);
}

pub fn contains(self: *const IgnoreAliases, name: []const u8) bool {
    return self.map.contains(name);
}

pub fn get(self: *const IgnoreAliases, name: []const u8) ?IgnoreAlias {
    return self.map.get(name);
}

pub fn remove(self: *IgnoreAliases, name: []const u8) bool {
    return self.map.remove(name);
}

pub fn iterator(self: *const IgnoreAliases) Iterator {
    return self.map.iterator();
}

pub fn keyIterator(self: *const IgnoreAliases) KeyIterator {
    return self.map.keyIterator();
}

fn cloneFromJSON(
    gpa: mem.Allocator,
    parsed: *const json.Parsed(json.ArrayHashMap(IgnoreAlias)),
) mem.Allocator.Error!IgnoreAliases {
    var result: HashMapType = .empty;

    var it = parsed.value.map.iterator();
    while (it.next()) |entry| {
        const name = try gpa.alloc(u8, entry.key_ptr.*.len);
        mem.copyForwards(u8, name, entry.key_ptr.*);
        const copy = alias_templates_are: {
            var array_list: std.ArrayListUnmanaged([]const u8) = .empty;
            defer array_list.deinit(gpa);
            for (entry.value_ptr.*) |template| {
                const template_copy = try gpa.alloc(u8, template.len);
                mem.copyForwards(u8, template_copy, template);
                try array_list.append(gpa, template_copy);
            }
            break :alias_templates_are try array_list.toOwnedSlice(gpa);
        };
        utils.sortStringSlice(copy);

        try result.put(gpa, name, copy);
    }

    return .{ .map = result };
}

pub fn parseFromSlice(
    gpa: mem.Allocator,
    s: []const u8,
) (ParseError || mem.Allocator.Error)!IgnoreAliases {
    const parsed = try json.parseFromSlice(json.ArrayHashMap(IgnoreAlias), gpa, s, .{});
    defer parsed.deinit();

    return try IgnoreAliases.cloneFromJSON(gpa, &parsed);
}

pub fn parseFromReader(gpa: mem.Allocator, reader: anytype) !IgnoreAliases {
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

pub fn deinit(self: *IgnoreAliases, gpa: mem.Allocator) void {
    var it = self.iterator();
    while (it.next()) |entry| {
        gpa.free(entry.key_ptr.*);
        for (entry.value_ptr.*) |template| {
            gpa.free(template);
        }
        gpa.free(entry.value_ptr.*);
    }
    self.map.deinit(gpa);
}

fn getSortedKeys(self: *const IgnoreAliases, gpa: mem.Allocator) ![]const []const u8 {
    var array_list: std.ArrayListUnmanaged([]const u8) = .empty;
    defer array_list.deinit(gpa);

    var it = self.keyIterator();
    while (it.next()) |alias_name| {
        try array_list.append(gpa, alias_name.*);
    }

    const owned = try array_list.toOwnedSlice(gpa);
    utils.sortStringSlice(owned);

    return owned;
}

pub fn writeSerialized(self: *const IgnoreAliases, gpa: mem.Allocator, writer: anytype) !void {
    const alias_names = try self.getSortedKeys(gpa);
    defer gpa.free(alias_names);

    var streamer = json.writeStream(writer, .{});
    try streamer.beginObject();

    for (alias_names) |alias_name| {
        try streamer.objectField(alias_name);
        try streamer.write(self.get(alias_name).?);
    }

    try streamer.endObject();
    _ = try writer.write("\n");
}

pub fn writeAliases(self: *const IgnoreAliases, gpa: mem.Allocator, writer: anytype) !void {
    const alias_names = try self.getSortedKeys(gpa);
    defer gpa.free(alias_names);

    for (alias_names) |alias| {
        const joined = try mem.join(gpa, ", ", self.get(alias).?);
        defer gpa.free(joined);
        try writer.print("{s} => [{s}]\n", .{ alias, joined });
    }
}

pub fn expandAliases(
    self: *const IgnoreAliases,
    gpa: mem.Allocator,
    names: []const []const u8,
) ![]const []const u8 {
    const expanded: [][]const u8 = deduped_expansion_is: {
        var hash_map: std.StringHashMapUnmanaged(bool) = .empty;
        defer hash_map.deinit(gpa);

        for (names) |name| {
            if (self.get(name)) |alias| {
                for (alias) |template| {
                    try hash_map.put(gpa, template, true);
                }
            } else {
                try hash_map.put(gpa, name, true);
            }
        }

        var array_list: std.ArrayListUnmanaged([]const u8) = .empty;
        defer array_list.deinit(gpa);

        var it = hash_map.keyIterator();
        while (it.next()) |template| {
            try array_list.append(gpa, template.*);
        }

        break :deduped_expansion_is try array_list.toOwnedSlice(gpa);
    };

    utils.sortStringSlice(expanded);

    return expanded;
}

test "clonefromJSON" {
    const gpa = testing.allocator;
    const data =
        \\{
        \\  "zig": ["visualstudiocode", "zig"]
        \\}
    ;
    const parsed = try json.parseFromSlice(json.ArrayHashMap(IgnoreAlias), gpa, data, .{});
    defer parsed.deinit();

    var ignore_aliases = try IgnoreAliases.cloneFromJSON(gpa, &parsed);
    defer ignore_aliases.deinit(gpa);

    try testing.expectEqual(1, ignore_aliases.map.size);
    try testing.expect(ignore_aliases.contains("zig"));
    try testing.expectEqual(2, ignore_aliases.get("zig").?.len);
}

test "parseFromSlice" {
    const gpa = testing.allocator;
    const data =
        \\{
        \\  "zig": ["visualstudiocode", "zig"]
        \\}
    ;
    var ignore_aliases = try IgnoreAliases.parseFromSlice(gpa, data);
    defer ignore_aliases.deinit(gpa);

    try testing.expectEqual(1, ignore_aliases.map.size);
    try testing.expect(ignore_aliases.contains("zig"));
    try testing.expectEqual(2, ignore_aliases.get("zig").?.len);
}

const std = @import("std");
const json = std.json;
const mem = std.mem;
const testing = std.testing;

const utils = @import("utils.zig");
const IgnoreFiles = @import("ignore_files.zig");
