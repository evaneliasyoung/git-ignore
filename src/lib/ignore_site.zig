const std = @import("std");

pub const IgnoreSite = @This();

pub const ParseError = std.Uri.ParseError;
pub const OpenError = std.Io.File.OpenError || std.Io.Dir.CreateDirError;
pub const FetchError = ParseError || std.http.Client.FetchError;
pub const DownloadError = OpenError || std.Io.File.Writer.WriteFileError || FetchError;

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

fn fetch(self: *const IgnoreSite, io: std.Io, gpa: std.mem.Allocator) FetchError![]const u8 {
    var client = std.http.Client{ .allocator = gpa, .io = io };
    defer client.deinit();

    var output_buffer: std.Io.Writer.Allocating = .init(gpa);
    defer output_buffer.deinit();

    _ = try client.fetch(.{
        .response_writer = &output_buffer.writer,
        .location = .{ .uri = self.endpoint },
        .method = .GET,
    });

    return try output_buffer.toOwnedSlice();
}

fn openFile(io: std.Io, output_file: []const u8) OpenError!std.Io.File {
    if (std.fs.path.dirname(output_file)) |parent_dir| {
        std.Io.Dir.createDirAbsolute(io, parent_dir, .default_file) catch |err| switch (err) {
            std.Io.Dir.CreateDirError.PathAlreadyExists => {},
            else => |e| return e,
        };
    }
    return try std.Io.Dir.createFileAbsolute(io, output_file, .{
        .read = false,
        .truncate = true,
        .exclusive = false,
    });
}

pub fn download(
    self: *const IgnoreSite,
    io: std.Io,
    gpa: std.mem.Allocator,
    output_file: []const u8,
) DownloadError!void {
    const file = try openFile(io, output_file);
    defer file.close(io);

    const data = try self.fetch(io, gpa);
    defer gpa.free(data);

    var writer = file.writer(io, &.{});
    try writer.interface.writeAll(data);
}

test "init" {
    const site = try init("https://www.gitignore.io/api/list?format=json");

    try std.testing.expectEqualDeep(default, site);
}
