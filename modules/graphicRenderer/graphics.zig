pub const std = @import("std");
pub const openGL = @import("opengl/opengl.zig");
pub const Vulkan = @import("vulkan/vulkan.zig");
pub const DX12 = @import("dx/dx12.zig");
pub const DX11 = @import("dx/dx11.zig");
pub const DX9 = @import("dx/dx9.zig");
pub const Metal = @import("metal/metal.zig");
pub const WebGPU = @import("web/webgpu.zig");
pub const WebGL = @import("web/webgl.zig");


// TODO investigate what this does
// pub const Renderer = union(enum) {
//     OpenGL: openGL.Renderer,
//     Vulkan: Vulkan.Renderer,
//     DX12: DX12.Renderer,
//     DX11: DX11.Renderer,
//     DX9: DX9.Renderer,
//     Metal: Metal.Renderer,
//     WebGPU: WebGPU.Renderer,
// };