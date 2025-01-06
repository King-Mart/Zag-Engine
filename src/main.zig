const std = @import("std");
const Ziglib = @import("Ziglib");
const config = @import("config");
pub const UNICODE = config.UNICODE;


//What is this?
// pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace) noreturn {
//     _ = error_return_trace;
//     @panic(msg);
// }





pub fn wWinMain(hInstance: Ziglib.window.HINSTANCE, hPrevInstance: ?Ziglib.window.HINSTANCE, lpCmdLine: ?[*]u16, nCmdShow: i32) i32 {
    std.debug.print("wWinMain called\n", .{});
    // Mark unused parameters as unused
    _ = nCmdShow;
    _ = hPrevInstance;
    const test_window = Ziglib.window.window;
    const other_window = Ziglib.window.window;
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
    test_window.createWindowClass(hInstance) catch |err| {
        std.debug.print("Error creating window class: {s}\n", .{@errorName(err)});
        return 1;
    };
    _ = test_window.registerClass();

    test_window.createWindow() catch |err| {
        std.debug.print("Error creating window: {s}\n", .{@errorName(err)});
        return 1;
    };
    test_window.showWindow() catch |err| {
        std.debug.print("Error showing window: {s}\n", .{@errorName(err)});
        return 1;
    };
    other_window.titleW = Ziglib.window.L("Other Window");

    // other_window.title = "Other Window"; poses problem

    other_window.createWindowClass(hInstance) catch |err| {
        std.debug.print("Error creating window class: {s}\n", .{@errorName(err)});
        return 1;
    };
    _ = test_window.registerClass();
    

    other_window.createWindow() catch |err| {
        std.debug.print("Error creating window: {s}\n", .{@errorName(err)});
        return 1;
    };
    other_window.showWindow() catch |err| {
        std.debug.print("Error showing window: {s}\n", .{@errorName(err)});
        return 1;
    };

    test_window.updateWindow() catch |err| {
        std.debug.print("Error updating window: {s}\n", .{@errorName(err)});
        return 1;
    };
    test_window.messageLoop() catch |err| {
        std.debug.print("Error in message loop: {s}\n", .{@errorName(err)});
        return 1;
    };
    other_window.updateWindow() catch |err| {
        std.debug.print("Error updating window: {s}\n", .{@errorName(err)});
        return 1;
    };
    other_window.messageLoop() catch |err| {
        std.debug.print("Error in message loop: {s}\n", .{@errorName(err)});
        return 1;
    };
    return 0;
    
}
