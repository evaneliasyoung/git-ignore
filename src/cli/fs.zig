const std = @import("std");

const known_folders = @import("known_folders");

const cli = @import("cli.zig");

pub const DirectoryError = error{NotFound} || known_folders.Error || std.mem.Allocator.Error;

pub fn getConfigPath(io: std.Io, gpa: std.mem.Allocator, environ: *std.process.Environ.Map) DirectoryError![]const u8 {
    if (try known_folders.getPath(io, gpa, environ, .roaming_configuration)) |roaming_path| {
        defer gpa.free(roaming_path);
        return try std.fs.path.join(gpa, &[_][]const u8{ roaming_path, "dev.eyoung.git-ignore" });
    } else {
        return DirectoryError.NotFound;
    }
}

pub fn getCachePath(io: std.Io, gpa: std.mem.Allocator, environ: *std.process.Environ.Map, config_path: ?[]const u8) DirectoryError![]const u8 {
    const config = config_path orelse try cli.fs.getConfigPath(io, gpa, environ);
    defer {
        if (config_path == null) gpa.free(config);
    }
    return try std.fs.path.join(gpa, &[_][]const u8{
        config,
        "ignore.json",
    });
}

pub fn getAliasesPath(io: std.Io, gpa: std.mem.Allocator, environ: *std.process.Environ.Map, config_path: ?[]const u8) DirectoryError![]const u8 {
    const config = config_path orelse try cli.fs.getConfigPath(io, gpa, environ);
    defer {
        if (config_path == null) gpa.free(config);
    }
    return try std.fs.path.join(gpa, &[_][]const u8{
        config,
        "aliases.json",
    });
}

pub fn existsAbsolute(io: std.Io, path: []const u8) bool {
    var path_exists: ?bool = null;
    std.Io.Dir.accessAbsolute(io, path, .{}) catch |err| {
        path_exists = err != error.FileNotFound;
    };
    return path_exists orelse true;
}

pub fn exists(io: std.Io, sub_path: []const u8) bool {
    var sub_path_exists: ?bool = null;
    std.Io.Dir.access(.cwd(), io, sub_path, .{}) catch |err| {
        sub_path_exists = err != error.FileNotFound;
    };
    return sub_path_exists orelse true;
}

pub fn gitIgnoreExists(io: std.Io) bool {
    return cli.fs.exists(io, ".gitignore");
}
