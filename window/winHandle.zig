const std = @import("std");
const win32 = std.os.windows;

// Define the entry point with the correct signature for Windows apps
pub fn wWinMain(hInstance: win32.HINSTANCE, hPrevInstance: ?win32.HINSTANCE, lpCmdLine: ?[*]u16, nCmdShow: i32) i32 {
    // Mark unused parameters as unused
    _ = nCmdShow;
    _ = hPrevInstance;

    // If lpCmdLine is not null, handle it properly
    if (lpCmdLine != null) {
        const cmdLine = lpCmdLine.?[0..std.mem.len(lpCmdLine.?)];
        // Now cmdLine is a *u16, which is a wide string (UTF-16)
        std.debug.print("Command line: {}\n", .{cmdLine});
    } else {
        std.debug.print("No command line arguments\n", .{});
    }
    // Define a window class
    var window_class: win32.WNDCLASSW = .{
        .style = 0,
        .lpfnWndProc = WindowProc,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = hInstance,
        .hIcon = null,
        .hCursor = win32.LoadCursorW(null, win32.IDC_ARROW),
        .hbrBackground = win32.GetStockObject(win32.COLOR_WINDOW),
        .lpszMenuName = null,
        .lpszClassName = "ZigWindowClass",
    };

    // Register the window class
    if (win32.RegisterClassW(&window_class) == 0) {
        return std.log.err("Failed to register window class: {}", .{win32.GetLastError()});
    }

    // Create the window
    const hwnd = win32.CreateWindowExW(
        0,
        window_class.lpszClassName,
        "Zig Window",
        win32.WS_OVERLAPPEDWINDOW,
        win32.CW_USEDEFAULT, win32.CW_USEDEFAULT,
        800, 600,
        null, null, hInstance, null,
    );

    if (hwnd == null) {
        return std.log.err("Failed to create window: {}", .{win32.GetLastError()});
    }

    win32.ShowWindow(hwnd, win32.SW_SHOW);
    win32.UpdateWindow(hwnd);

    // Run the message loop
    var msg: win32.MSG = undefined;
    while (win32.GetMessageW(&msg, null, 0, 0) > 0) {
        win32.TranslateMessage(&msg);
        win32.DispatchMessageW(&msg);
    }

    return 0;
}

// WindowProc function to handle messages
fn WindowProc(hwnd: win32.HWND, msg: u32, wparam: usize, lparam: isize) win32.LRESULT {
    switch (msg) {
        win32.WM_DESTROY => {
            win32.PostQuitMessage(0);
            return 0;
        },
        else => return win32.DefWindowProcW(hwnd, msg, wparam, lparam),
    }
}
