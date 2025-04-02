pub const IgnoreSite = @This();

pub const FetchError = Client.RequestError || Request.FinishError || Request.WaitError;
pub const ParseError = Uri.ParseError;
pub const OpenError = File.OpenError;
pub const ReadError = Request.Reader.Error;
pub const WriteError = File.WriteError;
pub const PipeError = ReadError || WriteError;

pub const default = IgnoreSite{
    .endpoint = Uri{
        .scheme = "https",
        .user = null,
        .password = null,
        .host = Uri.Component{
            .percent_encoded = "www.gitignore.io",
        },
        .port = null,
        .path = Uri.Component{
            .percent_encoded = "/api/list",
        },
        .query = Uri.Component{
            .percent_encoded = "format=json",
        },
        .fragment = null,
    },
};

endpoint: Uri,

pub fn init(endpoint: []const u8) ParseError!IgnoreSite {
    return .{ .endpoint = try Uri.parse(endpoint) };
}

fn fetch(self: *const IgnoreSite, gpa: Allocator) FetchError!Request {
    var client = Client{ .allocator = gpa };
    defer client.deinit();

    var buffer: [4096]u8 = undefined;
    var request = try client.open(.GET, self.endpoint, .{ .server_header_buffer = &buffer });
    defer request.deinit();

    try request.send();
    try request.finish();
    try request.wait();

    return request;
}

fn pipeRequestToFile(request: Request, file: File) PipeError!void {
    const FifoType = fifo.LinearFifo(u8, .{ .Static = 4096 });
    var buffer: FifoType = FifoType.init();
    defer buffer.deinit();

    try buffer.pump(request.reader(), file.writer());
}

pub fn download(
    self: *const IgnoreSite,
    gpa: Allocator,
    output_file: []const u8,
) (FetchError || OpenError || PipeError)!void {
    const request = try self.fetch(gpa);

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

const Allocator = mem.Allocator;
const Client = http.Client;
const File = fs.File;
const Request = Client.Request;
const Uri = std.Uri;
