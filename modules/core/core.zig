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

pub fn newWindow(self: *Window, hInstance: win32.HINSTANCE) !void {
        self.instance = hInstance;
        //Create the window class to describe what kind of window to create to the Windows operating system
        self.wc = win32.WNDCLASSEXW{
            .style = win32.CS_CLASSDC,
            .lpfnWndProc = self.WinProc,
            .cbClsExtra = 0,
            .cbSize = @sizeOf(win32.WNDCLASSEXW),
            .cbWndExtra = 0,
            .hInstance = hInstance,
            .hIcon = null,
            .hIconSm = null,
            .hCursor = null,
            .hbrBackground = null,
            .lpszMenuName = null,
            .lpszClassName = self.class_name,
        };

        //Tell window this is the class to use for our next window
        //And return error if encountered
        if (self.wc) |window_class| {
            if (win32.RegisterClassExW(&window_class) == 0) {
                return error.RegisterClassFailed;
            }
        }

        //Receive the window handle
        self.hwnd = win32.CreateWindowExW(
            win32.WS_EX_OVERLAPPEDWINDOW,
            self.class_name,
            self.titleW,
            win32.WS_OVERLAPPEDWINDOW,
            win32.CW_USEDEFAULT,
            win32.CW_USEDEFAULT,
            self.width,
            self.height,
            null,
            null,
            hInstance,
            null,
        );

        _ = win32.ShowWindow(self.hwnd, win32.SW_SHOW);
        _ = win32.UpdateWindow(self.hwnd);
    }
pub fn processMessages() bool {
    //Empty the message loop to handle them later
    var msg: win32.MSG = undefined;

    //here we peek at the message, if it tells us to quit then we send the info to the winproc and to the game window
    while (win32.PeekMessage(&msg, null, 0, 0, win32.PM_REMOVE) != 0) {
        if (msg.message == win32.WM_QUIT) {
            std.debug.print("WEEEEREE QUITTTING !!!! The message is {d} and the quit value is {d}\n", .{ msg.message, win32.WM_QUIT });
            return false;
        }
        //Translate char and input messages and add them to the queue
        _ = win32.TranslateMessage(&msg);
        //Either send the message to WinProc or in the case of a WM_TIMER message, we might have a fucntion to execute in the lparam
        _ = win32.DispatchMessage(&msg);
    }
    return true;
}
pub fn WinProc(wpHWND: win32.HWND, msg: u32, wparam: usize, lparam: isize) callconv(WINAPI) isize {
        // std.debug.print("WindowProc called, msg: {d}, wparam: {d}, lparam: {d}\n", .{ msg, wparam, lparam });
        switch (msg) {
            win32.WM_CLOSE => {
                //No ideea how to add confirmation after tonight's refactoring
                // if (!confirm_exit or (win32.MessageBoxExW(wpHWND, L("Are you sure you want to exit?"), L("Exit this amazing engine??"), win32.MB_OKCANCEL, 0) == win32.IDOK)) {
                //     _ = win32.DestroyWindow(wpHWND);
                // }
                // return 0;
                _ = win32.DestroyWindow(wpHWND);
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
                //TODO: use COM interfaces to shared my window struct information
                _ = win32.FillRect(hdc, &ps.rcPaint, win32.CreateSolidBrush(color.RGB(255, 255, 255).toCOLOREF()));
                _ = win32.EndPaint(wpHWND, &ps);
                return 0;
            },
            else => {
                return win32.DefWindowProc(wpHWND, msg, wparam, lparam);
            },
        }
}
pub const Window: type = struct {
    confirm_exit: bool,
    width: i16 = 640,
    height: i16 = 480,
    // pub var title: ?[*:0]const u8 = "Hello, world!"; poses problem
    titleW: ?[*:0]const u16 = L("Hello, world!"),
    class_name: ?[*:0]const u16 = L("HelloWindowClass"),
    instance: ?win32.HINSTANCE,
    wc: ?win32.WNDCLASSEXW = null,
    hwnd: ?HWND = null,
    background_color: color.rgb = color.RGB(255, 255, 255),
    WinProc: *const fn(wpHWND: win32.HWND, msg: u32, wparam: usize, lparam: isize) callconv(WINAPI) isize,
    //value pasted from an error log
    newWindow: *const fn (self: *Window, win32.HINSTANCE) @typeInfo(@typeInfo(@TypeOf(newWindow)).Fn.return_type.?).ErrorUnion.error_set!void,
    processMessages: *const fn() bool,
    // WinProc,
    // newWindow,
    // processMessages,
};

//This will be the engine that runs the game loop

pub const engine = struct {
    pub fn run(targetWindow: *Window) !void {
        var running = true;
        while (running) {
            running = targetWindow.processMessages();
        }
    }
};
