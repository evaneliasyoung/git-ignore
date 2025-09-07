const std = @import("std");

const known_folders = @import("known_folders");

const cli = @import("cli.zig");

pub const DirectoryError = error{NotFound} || known_folders.Error || std.mem.Allocator.Error;

pub fn getConfigPath(gpa: std.mem.Allocator) DirectoryError![]const u8 {
    if (try known_folders.getPath(gpa, .roaming_configuration)) |roaming_path| {
        defer gpa.free(roaming_path);
        return try std.fs.path.join(gpa, &[_][]const u8{ roaming_path, "dev.eyoung.git-ignore" });
    } else {
        return DirectoryError.NotFound;
    }
}

pub fn getCachePath(gpa: std.mem.Allocator, config_path: ?[]const u8) DirectoryError![]const u8 {
    const config = config_path orelse try cli.fs.getConfigPath(gpa);
    defer {
        if (config_path == null) gpa.free(config);
    }
    return try std.fs.path.join(gpa, &[_][]const u8{
        config,
        "ignore.json",
    });
}

pub fn getAliasesPath(gpa: std.mem.Allocator, config_path: ?[]const u8) DirectoryError![]const u8 {
    const config = config_path orelse try cli.fs.getConfigPath(gpa);
    defer {
        if (config_path == null) gpa.free(config);
    }
    return try std.fs.path.join(gpa, &[_][]const u8{
        config,
        "aliases.json",
    });
}

pub fn existsAbsolute(path: []const u8) bool {
    var path_exists: ?bool = null;
    std.fs.accessAbsolute(path, .{}) catch |err| {
        path_exists = err != error.FileNotFound;
    };
    return path_exists orelse true;
}

pub fn exists(sub_path: []const u8) bool {
    var sub_path_exists: ?bool = null;
    std.fs.cwd().access(sub_path, .{}) catch |err| {
        sub_path_exists = err != error.FileNotFound;
    };
    return sub_path_exists orelse true;
}

pub fn gitIgnoreExists() bool {
    return cli.fs.exists(".gitignore");
}
