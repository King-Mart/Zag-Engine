
use bindings::windows::core::PCWSTR;
use bindings::windows::Win32::Graphics::Gdi::{BeginPaint, CreateSolidBrush, EndPaint, FillRect, GetSysColor, GetSysColorBrush, PAINTSTRUCT};
//use bindings::windows::Win32::Foundation;
use bindings::windows::Win32::UI::WindowsAndMessaging::*;
// use bindings::windows::Win32::UI::Input::KeyboardAndMouse;

use bindings::windows::Win32::Foundation::{
    COLORREF, HINSTANCE, HWND, LPARAM, LRESULT, WPARAM
};
use std::os::windows::ffi::OsStrExt;
use bindings::windows::System::VirtualKey;

//PLACEHOLDER< TODO: UNDERSTAND and MODIFY this
fn to_wide_string(value: &str) -> Vec<u16> {
    std::ffi::OsStr::new(value).encode_wide().chain(std::iter::once(0)).collect()
}
fn to_pcwstr(value: &str) -> PCWSTR {
    static mut BUFFER: Vec<u16> = Vec::new();
    //TODO: Invetigate why Rust considers this dangerous behavior
    unsafe {
        BUFFER = to_wide_string(value);
        PCWSTR(BUFFER.as_ptr())
    }


}
extern "system" fn wnd_proc(hwnd: HWND, msg: u32, wparam: WPARAM, lparam: LPARAM) -> LRESULT {
    match msg {
        WM_KEYDOWN => {
            let key_pressed = VirtualKey(wparam.0 as i32);
            eprintln!("{:?} Key pressed", key_pressed);
            if key_pressed.0 == 78 {
                unsafe {
                let box_title = to_wide_string("Key pressed");
                let box_message = to_wide_string("N key was pressed");
                _ = MessageBoxW(Some(hwnd), PCWSTR(box_message.as_ptr()), PCWSTR(box_title.as_ptr()), MB_OKCANCEL)
                }
            }
            return LRESULT(0);
        }
        WM_PAINT => {
            eprintln!("WM_PAINT");
            let mut ps = PAINTSTRUCT::default();
            let hdc;
             unsafe {
                hdc  = BeginPaint(hwnd, &mut ps);
                _ = FillRect(hdc, &ps.rcPaint, CreateSolidBrush(COLORREF(0x0000FF_u32)));
                _ = EndPaint(hwnd, &ps);
            };

            return  LRESULT(0);
        }
        WM_CLOSE => {
            eprintln!("WM_CLOSE");
            _ = unsafe { DestroyWindow(hwnd) };
            return LRESULT(0);
        }
        WM_DESTROY => {
            eprintln!("WM_DESTROY");
            unsafe { PostQuitMessage(0) };
            return LRESULT(0);
        }
        _ => {
            eprintln!("Unknown message: 0x{:x}", msg);
            unsafe { DefWindowProcW(hwnd, msg, wparam, lparam) }
        }
    }
}


fn main() {
   //TODO: Add a unsuccesfull initialization handling
    let instance = match unsafe { bindings::windows::Win32::System::LibraryLoader::GetModuleHandleW(None) } {
        Ok(hmodule) => HINSTANCE(hmodule.0),
        Err(e) => {
            eprintln!("Failed to get HINSTANCE (init1): {:?}", e);
            return;
        }
    };
    

    let class_name = to_pcwstr("sample_class");

    
    let wc = WNDCLASSEXW {
        style: CS_CLASSDC,
        //I need to understand this Rust lyrical miracle
        lpfnWndProc: Some(wnd_proc),
        cbClsExtra: 0,
        cbSize: std::mem::size_of::<WNDCLASSEXW>() as u32,
        cbWndExtra: 0,
        hInstance: instance,
        //Since we need to gives values at the start and we do not know them yet, we pass on the defaults
        hIcon: Default::default(),
        hIconSm: Default::default(),
        hCursor: Default::default(),
        hbrBackground: Default::default(),
        lpszMenuName: PCWSTR::null(),
        lpszClassName: class_name,
    };
     if unsafe { 
            RegisterClassExW(&wc) == 0
        } {
            eprintln!("Failed to register the window class (init2")
        }

    let hwnd = 
        match          
            unsafe {
                    CreateWindowExW(
                    WS_EX_OVERLAPPEDWINDOW,
                    class_name,
                    to_pcwstr("Test"),
                    WS_OVERLAPPEDWINDOW,
                    CW_USEDEFAULT,
                    CW_USEDEFAULT,
                    900,
                    1600,
                    None,
                    None,
                    Some(instance),
                    None
                )
            } {
                Ok(hw) => hw,
                Err(error) => {
                    eprintln!("Failed to create the window (init3): {:?}",error);
                    panic!("Aborting")
                }

            };
    unsafe {
        _ = ShowWindow(hwnd, SW_SHOW);
        _ = bindings::windows::Win32::Graphics::Gdi::UpdateWindow(hwnd);
    }
    let mut msg: MSG = unsafe { std::mem::zeroed() };
    loop {
        let ret = unsafe { GetMessageW(&mut msg, None, 0, 0) };
    
        if ret.0 == -1 {
            eprintln!("GetMessageW failed!");
            break;
        } else if ret.0 == 0 {
            // WM_QUIT received
            break;
        }
    
        unsafe {
            _ = TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
    }
}
    
