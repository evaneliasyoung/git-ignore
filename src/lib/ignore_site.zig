const std = @import("std");

pub const IgnoreSite = @This();

pub const ParseError = std.Uri.ParseError;
pub const OpenError = std.fs.File.OpenError || std.fs.Dir.MakeError;
pub const FetchError = (ParseError ||
    std.http.Client.Request.ReadError ||
    std.http.Client.Request.SendError ||
    std.http.Client.Request.WaitError ||
    std.http.Client.Request.WriteError ||
    std.http.Client.Request.FinishError ||
    error{StreamTooLong});
pub const DownloadError = (OpenError || std.fs.File.WriteError || FetchError);

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

fn fetch(self: *const IgnoreSite, gpa: std.mem.Allocator) FetchError![]const u8 {
    var client = std.http.Client{ .allocator = gpa };
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

fn openFile(output_file: []const u8) OpenError!std.fs.File {
    if (std.fs.path.dirname(output_file)) |parent_dir| {
        std.fs.makeDirAbsolute(parent_dir) catch |err| switch (err) {
            std.fs.Dir.MakeError.PathAlreadyExists => {},
            else => |e| return e,
        };
    }
    return try std.fs.createFileAbsolute(output_file, .{
        .read = false,
        .truncate = true,
        .exclusive = false,
    });
}

pub fn download(
    self: *const IgnoreSite,
    gpa: std.mem.Allocator,
    output_file: []const u8,
) DownloadError!void {
    const file = try openFile(output_file);
    defer file.close();

    const data = try self.fetch(gpa);
    defer gpa.free(data);

    try file.writeAll(data);
}

test "init" {
    const site = try init("https://www.gitignore.io/api/list?format=json");

    try std.testing.expectEqualDeep(default, site);
}
