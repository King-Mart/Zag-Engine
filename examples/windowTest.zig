pub const Ziglib = @import("Ziglib");
pub const std = @import("std");
pub const L = Ziglib.core.L;

//It is important to st up the unicode constant before starting
pub const UNICODE = @import("config").UNICODE;

pub fn wWinMain(hInstance: Ziglib.core.HINSTANCE, hPrevInstance: ?Ziglib.core.HINSTANCE, lpCmdLine: ?[*]u16, nCmdShow: i32) i32 {
    std.debug.print("wWinMain called\n", .{});
    // Mark unused parameters as unused
    _ = nCmdShow;
    _ = hPrevInstance;
    var test_window: Ziglib.core.Window = .{ 
        .background_color = Ziglib.graphics.color.RGB(34, 146, 210),
        .class_name = L("The real test baby"),
        .confirm_exit = false,
        .height = 1080,
        .width = 1800,
        .instance = hInstance,
        .WinProc = Ziglib.core.WinProc,
        .processMessages = Ziglib.core.processMessages,
        .newWindow = Ziglib.core.newWindow,
        };
    test_window.background_color = Ziglib.graphics.color.RGB(102, 255, 12);
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
    //You can change the backrgound color
    //Now you create the window, it won't process its messages on its own
    Ziglib.core.newWindow(&test_window, hInstance) catch |err| {
        std.debug.print("Error creating window: {s}\n", .{@errorName(err)});
        return 1;                   
    };
    //You have to process them manually
    const engine = Ziglib.core.engine;
    try engine.run(&test_window);




    return 0;
}