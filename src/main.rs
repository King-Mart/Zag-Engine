
//use bindings::windows::Win32::Foundation;
use bindings::windows::Win32::UI::WindowsAndMessaging;
// use bindings::windows::Win32::UI::Input::KeyboardAndMouse;

use bindings::windows::Win32::Foundation::{
    HWND, 
    HINSTANCE,
    WPARAM,
    LPARAM,
    LRESULT,
};
use std::os::windows::ffi::OsStrExt;

//PLACEHOLDER< TODO: UNDERSTAND and MODIFY this
fn to_wide_string(value: &str) -> Vec<u16> {
    std::ffi::OsStr::new(value).encode_wide().chain(std::iter::once(0)).collect()
}
extern "system" fn wnd_proc(hwnd: HWND, msg: u32, wparam: WPARAM, lparam: LPARAM) -> LRESULT {
    unsafe { WindowsAndMessaging::DefWindowProcW(hwnd, msg, wparam, lparam) }
}

fn main() {
    let hmodule = unsafe {bindings::windows::Win32::System::LibraryLoader::GetModuleHandleW(None)};
    //TODO: Add a unsuccesfull initialization handling
    let instance = HINSTANCE(hmodule.unwrap().0);

    let class_name = to_wide_string("sample_class");
    let class_name_pcwstr = bindings::windows::core::PCWSTR(class_name.as_ptr());

    
    let _wc = WindowsAndMessaging::WNDCLASSEXW {
        style: WindowsAndMessaging::CS_CLASSDC,
        //I need to understand this Rust lyrical magical
        lpfnWndProc: Some(wnd_proc),
        cbClsExtra: 0,
        cbSize: std::mem::size_of::<WindowsAndMessaging::WNDCLASSEXW>() as u32,
        cbWndExtra: 0,
        hInstance: instance,
        //more Rust lyrical miracle
        hIcon: Default::default(),
        hIconSm: Default::default(),
        hCursor: Default::default(),
        hbrBackground: Default::default(),
        lpszMenuName: bindings::windows::core::PCWSTR::null(),
        lpszClassName: class_name_pcwstr,
    };
    println!("Hello, world!");
    println!("Printing something");
    let variable = 3;
    println!("The value of the variable I just made is {}", variable);
}
