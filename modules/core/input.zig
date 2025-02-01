const std = @import("std");
const win32 = struct {
    usingnamespace @import("win32.zig");
    usingnamespace @import("win32.zig").ui.input.keyboard_and_mouse;
};

pub fn getCharsFromKey () !void {}

pub fn printKey(key : win32.VIRTUAL_KEY) void {
    std.debug.print("The pressed key is {d}", .{@intFromEnum(key)});
}

