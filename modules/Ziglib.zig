//! NOTE: this file is an intermediate file, DO NOT MODIFY
pub const core = @import("core/core.zig");
pub const file = @import("file/file.zig");
pub const graphics = @import("core/graphics.zig");
pub const input = @import("core/input.zig");
pub const math = @import("math/math.zig");
pub const network = @import("networking/network.zig");
//pub const physics = @import("physics/physics.zig"); //TODO add a physics engine

test {
    @import("std").testing.refAllDecls(@This());
}
