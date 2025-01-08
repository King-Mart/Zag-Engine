//! NOTE: this file is aan intermediate file, DO NOT MODIFY
pub const core = @import("core.zig");
pub const file = @import("file/file.zig");
pub const graphics = @import("graphics/graphics.zig");
pub const input = @import("inputHandler/input.zig");
pub const math = @import("math/math.zig");
pub const network = @import("networking/network.zig");
//pub const physics = @import("physics/physics.zig"); //TODO add a physics engine
pub const window = @import("window/winHandle.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
