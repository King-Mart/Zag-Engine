const math = @import("../math/math.zig");
const std = @import("std");


pub const rgb = struct {
    r: f32,
    g: f32,
    b: f32,
};

pub const hsv = struct {
    h: f32,
    s: f32,
    v: f32,
};

pub fn RGB(r: f32, g: f32, b: f32) rgb {
    // if (r>1.0 or g>1.0 or b>1.0) {
    //     return error.InvalidColor;
    // }
    return rgb{ .r = r, .g = g, .b = b };
}
pub fn RGB255(r: u8, g: u8, b: u8) rgb{

    //TODO perhaps the conversion can be optimized
    return rgb{
        .r = @as(f32,@floatFromInt(r)) / 255.0,
        .g = @as(f32,@floatFromInt(g)) / 255.0,
        .b = @as(f32,@floatFromInt(b)) / 255.0,
        };
}

pub fn RGBtoWIN32(RGBcolor : rgb) u32 {

    // std.debug.print("RGBtoWIN32: {d} {d} {d}\n", .{RGBcolor.r, RGBcolor.g, RGBcolor.b});
    // std.debug.print("Result hex: {x}\n", .{@as(u32,@intFromFloat(RGBcolor.r * 16711680 + RGBcolor.g * 65280 + RGBcolor.b * 255))});

    return @intFromFloat(RGBcolor.b * 16711680 + RGBcolor.g * 65280 + RGBcolor.r * 255);
}

pub fn RGBtoHSV(RGBcolor : rgb) hsv {
    return RGBcolor;
}
pub fn RGBfromHSV(HSVcolor : hsv) rgb {
    return HSVcolor;
}