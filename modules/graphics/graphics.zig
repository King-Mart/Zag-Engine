pub const std = @import("std");

pub const renderer = @import("renderers/renderer.zig");
pub const color = @import("color.zig");

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