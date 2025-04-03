pub const IgnoreSite = @This();

pub const ParseError = std.Uri.ParseError;
pub const OpenError = fs.File.OpenError || fs.Dir.MakeError;

pub const default = IgnoreSite{
    .endpoint = std.Uri{
        .scheme = "https",
        .user = null,
        .password = null,
        .host = std.Uri.Component{
            .percent_encoded = "www.gitignore.io",
        },
        .port = null,
        .path = std.Uri.Component{
            .percent_encoded = "/api/list",
        },
        .query = std.Uri.Component{
            .percent_encoded = "format=json",
        },
        .fragment = null,
    },
};

endpoint: std.Uri,

pub fn init(endpoint: []const u8) ParseError!IgnoreSite {
    return .{ .endpoint = try std.Uri.parse(endpoint) };
}

fn fetch(self: *const IgnoreSite, gpa: mem.Allocator) ![]const u8 {
    var client = http.Client{ .allocator = gpa };
    defer client.deinit();

    var header_buffer: [4096]u8 = undefined;
    var output_buffer = std.ArrayList(u8).init(gpa);
    defer output_buffer.deinit();

    _ = try client.fetch(.{
        .server_header_buffer = &header_buffer,
        .response_storage = .{ .dynamic = &output_buffer },
        .location = .{ .uri = self.endpoint },
        .method = .GET,
    });

    return try output_buffer.toOwnedSlice();
}

fn openFile(output_file: []const u8) OpenError!fs.File {
    if (fs.path.dirname(output_file)) |parent_dir| {
        fs.makeDirAbsolute(parent_dir) catch |err| switch (err) {
            fs.Dir.MakeError.PathAlreadyExists => {},
            else => |e| return e,
        };
    }
    return try fs.createFileAbsolute(output_file, .{
        .read = false,
        .truncate = true,
        .exclusive = false,
    });
}

pub fn download(self: *const IgnoreSite, gpa: mem.Allocator, output_file: []const u8) !void {
    const file = try openFile(output_file);
    defer file.close();

    const data = try self.fetch(gpa);
    defer gpa.free(data);

    try file.writeAll(data);
}

test "init" {
    const site = try init("https://www.gitignore.io/api/list?format=json");

    try testing.expectEqualDeep(default, site);
}

const std = @import("std");
const fs = std.fs;
const http = std.http;
const mem = std.mem;
const testing = std.testing;
