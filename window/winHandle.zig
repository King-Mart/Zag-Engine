pub const UNICODE = true;
const std = @import("std");
const WINAPI = std.os.windows.WINAPI;

const win32 = struct {
    usingnamespace @import("win32").zig;
    usingnamespace @import("win32").foundation;
    usingnamespace @import("win32").system.system_services;
    usingnamespace @import("win32").ui.windows_and_messaging;
    usingnamespace @import("win32").graphics.gdi;
};
const L = win32.L;
const HWND = win32.HWND;

// Define the entry point with the correct signature for Windows apps

pub export fn wWinMain(hInstance: win32.HINSTANCE, hPrevInstance: ?win32.HINSTANCE, lpCmdLine: ?[*]u16, nCmdShow: i32) i32 {
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
    var window_class: win32.WNDCLASSEXW = .{
        .style = win32.CS_HREDRAW,
        .lpfnWndProc = WindowProc,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = hInstance,
        .hIcon = null,
        .hIconSm = null,
        .hCursor = win32.LoadCursorW(null, win32.IDC_ARROW),
        .hbrBackground = win32.GetStockObject(win32.WHITE_BRUSH),
        .cbSize = @sizeOf(win32.WNDCLASSEXW),
        .lpszMenuName = null,
        .lpszClassName = L("ZigWindowClass"),
    };

    // Register the window class
    if (win32.RegisterClassExW(&window_class) == 0) {
        //TODO Convert error code into i32
        const error_code = win32.GetLastError();
        std.log.err("Failed to register window class: {}", .{error_code});
        return 1;
    }

    // Create the window
    const hwnd = win32.CreateWindowExW(
        win32.WS_EX_OVERLAPPEDWINDOW,
        window_class.lpszClassName,
        L("Zig Window"),
        win32.WS_OVERLAPPEDWINDOW,
        win32.CW_USEDEFAULT,
        win32.CW_USEDEFAULT,
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
        const error_code = win32.GetLastError();
        std.log.err("Failed to register window class: {}", .{error_code});
        return 2;
    }

    std.debug.assert(hwnd != null);
    _ = win32.ShowWindow(hwnd, win32.SW_SHOW);
    _ = win32.UpdateWindow(hwnd);

    // Run the message loop
    var msg: win32.MSG = undefined;
    while (win32.GetMessageW(&msg, null, 0, 0) > 0) {
        _ = win32.TranslateMessage(&msg);
        _ = win32.DispatchMessageW(&msg);
    }

    return 0;
}

// WindowProc function to handle messages
fn WindowProc(hwnd: win32.HWND, msg: u32, wparam: usize, lparam: isize) callconv(.C) isize {
    switch (msg) {
        win32.WM_DESTROY => {
            win32.PostQuitMessage(0);
            return 0;
        },
        win32.WM_PAINT => {
            var ps: win32.PAINTSTRUCT = undefined;
            const hdc = win32.BeginPaint(hwnd, &ps);
            _ = win32.FillRect(hdc, &ps.rcPaint, win32.CreateSolidBrush(0xFF0000));
            //why does a value of 52 shows hello         | Z i g W i n d o w C l a s s
            _ = win32.TextOutA(hdc, 20, 20, "Hello", 52);
            _ = win32.EndPaint(hwnd, &ps);
            return 0;
        },
        else => return win32.DefWindowProcW(hwnd, msg, wparam, lparam), //win32.DefWindowProcW(hwnd, msg, wparam, lparam),
    }
}
