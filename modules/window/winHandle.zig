pub const UNICODE = true;
const std = @import("std");
const WINAPI = std.os.windows.WINAPI;

const win32 = struct {
    usingnamespace @import("win32.zig").zig;
    usingnamespace @import("win32.zig").foundation;
    usingnamespace @import("win32.zig").system.system_services;
    usingnamespace @import("win32.zig").ui.windows_and_messaging;
    usingnamespace @import("win32.zig").graphics.gdi;
};
const L = win32.L;
const HWND = win32.HWND;



pub const window = struct {
    var width: i16 = 640;
    var height: i16 = 480;
    var title = L("Hello, world!");
    var class_name: ?[*:0]const u16 = L("HelloWindowClass");
    var instance: win32.HINSTANCE = undefined;
    
    fn WinProc(hwnd: win32.HWND, msg: u32, wparam: usize, lparam: isize) callconv(WINAPI) isize {
        switch (msg) {
            win32.WM_DESTROY => {
                win32.PostQuitMessage(0);
                return 0;
            },
            else => {
                return win32.DefWindowProc(hwnd, msg, wparam, lparam);
            },
        }
    }
    const wc = win32.WNDCLASS{
            .style = win32.CS_CLASSDC,
            .lpfnWndProc = WinProc,    
            .cbClsExtra = 0,
            .cbWndExtra = 0,
            .hInstance = null,
            .hIcon = null,
            .hCursor = null,
            .hbrBackground = null,
            .lpszMenuName = null,
            .lpszClassName = L("HelloWindowClass"),
        };

    pub fn init() !void {
        
        _ = win32.RegisterClass(&wc);
        const hwnd = win32.CreateWindowEx(
            win32.WS_EX_OVERLAPPEDWINDOW,
            class_name,
            title,
            win32.WS_OVERLAPPEDWINDOW,
            win32.CW_USEDEFAULT,
            win32.CW_USEDEFAULT,
            width,
            height,
            null,
            null,
            instance,
            null,
        );
        if (hwnd == null) {
        
    }
    }

    fn createWindow() !void {
        
        if (win32.RegisterClass(&wc) == 0) {
            return win32.GetLastError();
        }
    }


    };



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
            const blueBrush = win32.CreateSolidBrush(0xFF0000);
            defer {
                _ = win32.DeleteObject(blueBrush);
            }
            _ = win32.FillRect(hdc, &ps.rcPaint, blueBrush);
            //why does a value of 52 shows hello         | Z i g W i n d o w C l a s s
            _ = win32.TextOutA(hdc, 20, 20, "Hello", 52);
            _ = win32.EndPaint(hwnd, &ps);
            return 0;
        },
        else => return win32.DefWindowProcW(hwnd, msg, wparam, lparam), //win32.DefWindowProcW(hwnd, msg, wparam, lparam),
    }
}
