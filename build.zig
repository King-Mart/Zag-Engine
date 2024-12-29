const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});
    // const mode = std.Build.ReleaseMode.fast; // Use Debug, ReleaseFast, or ReleaseSafe

    // Define executable options
    // const exe_main_options = std.Build.ExecutableOptions{
    //     .target = target,
    //     .name = "gameEngine",
    //     .optimize = optimize,
    // };

    // Define the gameEngine executable
    const exe_main = b.addExecutable(.{
        .name = "gameEngine",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_main.linkSystemLibrary("user32");
    // exe_main.setOutputDir("zig-out/bin");

    // Define the windowTest executable
    const exe_windowhandle = b.addExecutable(.{
        .name = "windowTest",
        .root_source_file = b.path("window/winHandle.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_windowhandle.linkSystemLibrary("user32");
    // exe_windowhandle.setOutputDir("zig-out/bin");
}
