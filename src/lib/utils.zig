const std = @import("std");
const mem = std.mem;
const testing = std.testing;

pub fn sortStringSlice(slices: [][]const u8) void {
    mem.sort([]const u8, slices, {}, struct {
        pub fn lessThan(_: void, lhs: []const u8, rhs: []const u8) bool {
            return mem.order(u8, lhs, rhs) == .lt;
        }
    }.lessThan);
}

test sortStringSlice {
    const gpa = testing.allocator;
    const items: [][]const u8 = try gpa.alloc([]const u8, 3);
    defer gpa.free(items);
    items[0] = "zig";
    items[1] = "python";
    items[2] = "visualstudiocode";
    sortStringSlice(items);

    try testing.expectEqualSlices(u8, "python", items[0]);
    try testing.expectEqualSlices(u8, "visualstudiocode", items[1]);
    try testing.expectEqualSlices(u8, "zig", items[2]);
}
