pub const IgnoreSite = @This();

pub const FetchError = (http.Client.RequestError ||
    http.Client.Request.FinishError ||
    http.Client.Request.WaitError);
pub const ParseError = std.Uri.ParseError;
pub const OpenError = fs.File.OpenError;
pub const ReadError = http.Client.Request.Reader.Error;
pub const WriteError = fs.File.WriteError;
pub const PipeError = ReadError || WriteError;

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

fn fetch(self: *const IgnoreSite, client: *http.Client) FetchError!http.Client.Request {
    var buffer: [4096]u8 = undefined;
    var request = try client.open(.GET, self.endpoint, .{ .server_header_buffer = &buffer });

    try request.send();
    try request.finish();
    try request.wait();

    return request;
}

fn pipeRequestToFile(request: http.Client.Request, file: fs.File) PipeError!void {
    const FifoType = fifo.LinearFifo(u8, .{ .Static = 4096 });
    var buffer: FifoType = FifoType.init();
    defer buffer.deinit();

    try buffer.pump(request.reader(), file.writer());
}

pub fn download(
    self: *const IgnoreSite,
    gpa: mem.Allocator,
    output_file: []const u8,
) (FetchError || OpenError || PipeError)!void {
    var client = http.Client{ .allocator = gpa };
    defer client.deinit();

    var request = try self.fetch(&client);
    defer request.deinit();

    const file = try fs.createFileAbsolute(output_file, .{
        .read = false,
        .truncate = true,
        .exclusive = false,
    });
    defer file.close();

    try pipeRequestToFile(request, file);
}

test "init" {
    const site = try init("https://www.gitignore.io/api/list?format=json");

    try testing.expectEqualDeep(default, site);
}

const std = @import("std");
const fifo = std.fifo;
const fs = std.fs;
const http = std.http;
const mem = std.mem;
const testing = std.testing;
