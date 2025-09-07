const std = @import("std");

pub fn sortStringSlice(slices: [][]const u8) void {
    std.mem.sort([]const u8, slices, {}, struct {
        pub fn lessThan(_: void, lhs: []const u8, rhs: []const u8) bool {
            return std.mem.order(u8, lhs, rhs) == .lt;
        }
    }.lessThan);
}

test sortStringSlice {
    const gpa = std.testing.allocator;
    const items: [][]const u8 = try gpa.alloc([]const u8, 3);
    defer gpa.free(items);
    items[0] = "zig";
    items[1] = "python";
    items[2] = "visualstudiocode";
    sortStringSlice(items);

    try std.testing.expectEqualSlices(u8, "python", items[0]);
    try std.testing.expectEqualSlices(u8, "visualstudiocode", items[1]);
    try std.testing.expectEqualSlices(u8, "zig", items[2]);
}
