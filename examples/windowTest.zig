pub const Ziglib = @import("Ziglib");
pub const std = @import("std");

//It is important to st up the unicode constant before starting
pub const UNICODE = @import("config").UNICODE;

pub fn wWinMain(hInstance: Ziglib.core.HINSTANCE, hPrevInstance: ?Ziglib.core.HINSTANCE, lpCmdLine: ?[*]u16, nCmdShow: i32) i32 {
    std.debug.print("wWinMain called\n", .{});
    // Mark unused parameters as unused
    _ = nCmdShow;
    _ = hPrevInstance;
    const test_window = Ziglib.core.window;
    // Having 2 windows doesn't work properly
    // const other_window = Ziglib.window.window;
    // If lpCmdLine is not null, handle it properly
    if (lpCmdLine) |cmdLine| {
        var cmdLineLen: usize = 0;
        while (cmdLine[cmdLineLen] != 0) {
            cmdLineLen += 1;
        }
        const cmdLineSlice = cmdLine[0..cmdLineLen];
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        var utf8CmdLineBuf = arena.allocator().alloc(u8, cmdLineLen * 4) catch |err| {
            std.debug.print("Error allocating memory: {s}\n", .{@errorName(err)});
            return 1;
        };
        defer arena.allocator().free(utf8CmdLineBuf);
        const utf8CmdLineLen = std.unicode.utf16leToUtf8(utf8CmdLineBuf, cmdLineSlice) catch |err| {
            std.debug.print("Error converting UTF-16 to UTF-8: {s}\n", .{@errorName(err)});
            return 1;
        };
        std.debug.print("Command line: {s}\n", .{utf8CmdLineBuf[0..utf8CmdLineLen]});
    } else {
        std.debug.print("No command line arguments\n", .{});
    }
    test_window.background_color = Ziglib.graphics.color.RGB(233, 123, 12);
    test_window.newWindow(hInstance) catch |err| {
        std.debug.print("Error creating window: {s}\n", .{@errorName(err)});
        return 1;                   
    };


    return 0;
}