pub const UNICODE = true;
const std = @import("std");
const WINAPI = std.os.windows.WINAPI;
const win32 = std.os.windows;
const WIN32 = @import("win32");
const user32 = WIN32.ui.windows_and_messaging;
const HINSTANCE = @import("win32").foundation.HINSTANCE;


// Define the entry point with the correct signature for Windows apps


pub export fn wWinMain(hInstance: HINSTANCE, hPrevInstance: ?HINSTANCE, lpCmdLine: ?[*]u16, nCmdShow: i32) i32 {
    std.debug.print("wWinMain called\n", .{});
    // Mark unused parameters as unused
    _ = nCmdShow;
    _ = hPrevInstance;

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
    // Define a window class
    var window_class: user32.WNDCLASSEXW = .{
        .style = user32.CS_HREDRAW,
        .lpfnWndProc = WindowProc,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = hInstance,
        .hIcon = null,
        .hIconSm = null,
        .hCursor = user32.LoadCursorW(null, user32.IDC_ARROW),
        .hbrBackground = WIN32.graphics.gdi.GetStockObject(WIN32.graphics.gdi.WHITE_BRUSH),
        .cbSize = @sizeOf(user32.WNDCLASSEXW),
        .lpszMenuName = null,
        .lpszClassName = WIN32.everything.L("ZigWindowClass"),
    };

    // Register the window class
    if (WIN32.ui.windows_and_messaging.RegisterClassExW(&window_class) == 0) {
        //TODO Convert error code into i32
        const error_code = WIN32.foundation.GetLastError();
        std.log.err("Failed to register window class: {}", .{error_code});
        return 1;
    }

    // Create the window
    const hwnd = user32.CreateWindowExW(
        user32.WS_EX_OVERLAPPEDWINDOW,
        window_class.lpszClassName,
        WIN32.zig.L("Zig Window"),
        user32.WS_OVERLAPPEDWINDOW,
        user32.CW_USEDEFAULT,
        user32.CW_USEDEFAULT,
        800,
        600,
        null,
        null,
        hInstance,
        null,
    );

    std.debug.print("hwnd: {any}\n", .{hwnd});

    if (hwnd == null) {
        //TODO Convert error code into i32
        const error_code = WIN32.foundation.GetLastError();
        std.log.err("Failed to register window class: {}", .{error_code});
        return 2;
    }

    std.debug.assert(hwnd != null);
    _ = user32.ShowWindow(hwnd, user32.SW_SHOW);
    _ = WIN32.graphics.gdi.UpdateWindow(hwnd);

    // Run the message loop
    var msg: user32.MSG = undefined;
    while (user32.GetMessageW(&msg, null, 0, 0) > 0) {
        _ = user32.TranslateMessage(&msg);
        _ = user32.DispatchMessageW(&msg);
    }

    return 0;
}

// WindowProc function to handle messages
fn WindowProc(hwnd: WIN32.foundation.HWND, msg: u32, wparam: usize, lparam: isize) callconv(.C) isize {
    std.debug.print("WindowProc called\n", .{});
    switch (msg) {
        user32.WM_DESTROY => {
            user32.PostQuitMessage(0);
            return 0;
        },
        else => return user32.DefWindowProcW(hwnd, msg, wparam, lparam)//win32.DefWindowProcW(hwnd, msg, wparam, lparam),
    }
}

pub fn main() !void {
    std.os.windows.link(wWinMain, "wWinMain");
    wWinMain(0, null, null, 0);
}