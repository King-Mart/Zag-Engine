//Will represent a standalone window class. What I would like to implement next is separation from the window API in order to simplify cross platform development.


use bindings::
        windows::{
            core::PCWSTR,
            Win32::{
                Foundation::{
                    COLORREF, HINSTANCE, HWND, LPARAM, LRESULT, WPARAM
                },
                Graphics::
                    Gdi::{
                    BeginPaint, CreateSolidBrush, DeleteObject, EndPaint, FillRect, GetSysColor, GetSysColorBrush, PAINTSTRUCT
                },
                UI::{
                    WindowsAndMessaging::*,
                    Input::KeyboardAndMouse,
                },
            },
            System::VirtualKey,

        };




use std::os::windows::ffi::OsStrExt;



//PLACEHOLDER< TODO: UNDERSTAND and MODIFY this
fn to_wide_string(value: &str) -> Vec<u16> {
    std::ffi::OsStr::new(value).encode_wide().chain(std::iter::once(0)).collect()
}

//WARNING: this function should not be used I am only keeping it to investigate why it allows to inject a different string than the one entered. It will be removed thereafter.
// fn to_pcwstr(value: &str) -> PCWSTR {
//     static mut BUFFER: Vec<u16> = Vec::new();
//     //TODO: Invetigate why Rust considers this dangerous behavior
//     unsafe {
//         BUFFER = to_wide_string(value);
//         PCWSTR(BUFFER.as_ptr())
//     }
// }
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
            let red_brush;
             unsafe {
                hdc  = BeginPaint(hwnd, &mut ps);
                red_brush = CreateSolidBrush(COLORREF(0x0000FF_u32));
                _ = FillRect(hdc, &ps.rcPaint, red_brush);
                _ = EndPaint(hwnd, &ps);
                _ = DeleteObject(red_brush.into());
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
    

    let class_name = to_wide_string("sample_class");

    
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
        lpszClassName: PCWSTR(class_name.as_ptr()),
    };
     if unsafe { 
            RegisterClassExW(&wc) == 0
        } {
            eprintln!("Failed to register the window class (init2")
        }
    let title = to_wide_string("Rust Window");
    let hwnd = 
        match          
            unsafe {
                    CreateWindowExW(
                    WS_EX_OVERLAPPEDWINDOW,
                    PCWSTR(class_name.as_ptr()),
                    PCWSTR(title.as_ptr()),
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
    
