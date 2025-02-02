//---
//- @author King-Mart
//- @dependsOn win32
//- To whoever reads this, this is the core file for the Zag engine
//- After many iterations, it was confusing to handle windows and the game loop in separate files and so I decided to put them all in the core file
//---

pub const UNICODE = true;
const std = @import("std");
const WINAPI = std.os.windows.WINAPI;
const input = @import("input.zig");

const win32 = struct {
    usingnamespace @import("win32.zig").zig;
    usingnamespace @import("win32.zig").foundation;
    usingnamespace @import("win32.zig").system.system_services;
    usingnamespace @import("win32.zig").ui.windows_and_messaging;
    usingnamespace @import("win32.zig").ui.input.keyboard_and_mouse;
    usingnamespace @import("win32.zig").graphics.gdi;
};
// Use the local color file for handling colors
const color = @import("color.zig");
pub const HINSTANCE = win32.HINSTANCE;
pub const L = win32.L;
const HWND = win32.HWND;

pub const window = struct {
    pub var confirm_exit: bool = false;
    pub var width: i16 = 640;
    pub var height: i16 = 480;
    // pub var title: ?[*:0]const u8 = "Hello, world!"; poses problem
    pub var titleW: ?[*:0]const u16 = L("Hello, world!");
    var class_name: ?[*:0]const u16 = L("HelloWindowClass");
    var instance: ?win32.HINSTANCE = null;
    var wc: ?win32.WNDCLASSEXW = null;
    var hwnd: ?HWND = null;
    pub var background_color: color.rgb = color.RGB(1.0, 1.0, 1.0);

    fn WinProc(wpHWND: win32.HWND, msg: u32, wparam: usize, lparam: isize) callconv(WINAPI) isize {
        std.debug.print("WindowProc called, msg: {d}, wparam: {d}, lparam: {d}\n", .{ msg, wparam, lparam });
        switch (msg) {
            win32.WM_CLOSE => {
                if (!confirm_exit or (win32.MessageBoxExW(wpHWND, L("Are you sure you want to exit?"), L("Exit this amazing engine??"), win32.MB_OKCANCEL, 0) == win32.IDOK)) {
                    _ = win32.DestroyWindow(wpHWND);
                }
                return 0;
            },
            win32.WM_KEYDOWN => {
                const keyPressed: win32.VIRTUAL_KEY = @enumFromInt(wparam);
                input.printKey(keyPressed);
                return 0;
            },
            win32.WM_DESTROY => {
                win32.PostQuitMessage(0);
                return 0;
            },
            win32.WM_PAINT => {
                var ps: win32.PAINTSTRUCT = undefined;
                const hdc = win32.BeginPaint(wpHWND, &ps);
                _ = win32.FillRect(hdc, &ps.rcPaint, win32.CreateSolidBrush(background_color.toCOLOREF()));
                _ = win32.EndPaint(wpHWND, &ps);
                return 0;
            },
            else => {
                return win32.DefWindowProc(wpHWND, msg, wparam, lparam);
            },
        }
    }

    pub fn newWindow(hInstance: win32.HINSTANCE) !void {
        instance = hInstance;
        //Create the window class to describe what kind of window to create to the Windows operating system
        wc = win32.WNDCLASSEXW{
            .style = win32.CS_CLASSDC,
            .lpfnWndProc = WinProc,
            .cbClsExtra = 0,
            .cbSize = @sizeOf(win32.WNDCLASSEXW),
            .cbWndExtra = 0,
            .hInstance = hInstance,
            .hIcon = null,
            .hIconSm = null,
            .hCursor = null,
            .hbrBackground = null,
            .lpszMenuName = null,
            .lpszClassName = class_name,
        };

        //Tell window this is the class to use for our next window
        //And return error if encountered
        if (wc) |window_class| {
            if (win32.RegisterClassExW(&window_class) == 0) {
                return error.RegisterClassFailed;
            }
        }

        //Receive the window handle
        hwnd = win32.CreateWindowExW(
            win32.WS_EX_OVERLAPPEDWINDOW,
            class_name,
            titleW,
            win32.WS_OVERLAPPEDWINDOW,
            win32.CW_USEDEFAULT,
            win32.CW_USEDEFAULT,
            width,
            height,
            null,
            null,
            hInstance,
            null,
        );

        _ = win32.ShowWindow(hwnd, win32.SW_SHOW);
        _ = win32.UpdateWindow(hwnd);

        //Empty the message loop to handle them later
        var msg: win32.MSG = undefined;
        //peekmessage is essential for the game loop but for a simple window, it creates the problem of being too fast and closign due to lack of received messages
        while (win32.GetMessage(&msg, hwnd, 0, 0, win32.PM_REMOVE) != 0) {
            _ = win32.TranslateMessage(&msg);
            _ = win32.DispatchMessage(&msg);
        }
    }
};

//This will be the engine that runs the game loop

const engine = struct {};
