const math = @import("../math/math.zig");
const std = @import("std");

//As of 2025 Jan 10, rgb was switched from f32 to u8

//TODO memory deallocation??
//TODO more color types
//TODO error handling
//TODO color conversion

// const Color = struct {
//     pub fn toCOLOREF() u32 {
//         return 0xFFFFFF;
//     }
// };

pub const rgb = struct {
    r: u8,
    g: u8,
    b: u8,

     pub fn toHex(self: rgb) u32 {
        return self.r << 16 | self.g << 8 | self.b;
     }

//TODO benchmark possibilites
     pub fn toCOLOREF(self: rgb) u32 {
        return @as(u32, self.b) << 16 | @as(u16,self.g) << 8 | self.r;
     }
};

pub const hsv = struct {
    h: f32,
    s: f32,
    v: f32,
};


pub fn RGB(r: u8, g: u8, b: u8) rgb {
    // if (r>1.0 or g>1.0 or b>1.0) {
    //     return error.InvalidColor;
    // }
    // const color : ColorType = ColorType{.rgb = rgb{.r = r, .g = g, .b = b}};
    // return color;
    return rgb{
        .r = r,
        .g = g,
        .b = b
        };
    }

pub const ColorType = union(enum) {
    rgb: rgb,
    hsv: hsv,
};


//Failed attempt to streamline color conversion
// pub fn toCOLOREF(color : struct {}) u32 {

//     // comptime {
//     //     if (!@hasDecl(ColorType, "toCOLOREF")) {
//     //         @compileError("color type does not have toCOLOREF function");
//     //     }
//     // }

//     comptime {
//         if (@hasDecl(ColorType, "rgb")) {
//             if (color == .rgb) {
//                 return color.rgb.toCOLOREF();
//             }
//         }
//         if (@hasDecl(ColorType, "hsv")) {
//             if (color == .hsv) {
//                 return color.hsv.toCOLOREF();
//             }
//         }
//     }

//     return 0xFFFFFF;

// }

pub fn RGBtoHSV(RGBcolor : rgb) hsv {
    return RGBcolor;
}
pub fn RGBfromHSV(HSVcolor : hsv) rgb {
    return HSVcolor;
}