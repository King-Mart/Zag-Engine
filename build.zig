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


    // Define the static library (gameEngine) for the main game logic
    const lib = b.addStaticLibrary(.{
        .name = "gameEngine",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Install the static library
    b.installArtifact(lib);

    // Define the gameEngine executable
    const exe_main = b.addExecutable(.{
        .name = "gameEngine",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Link system libraries

    // Install the gameEngine executable
    b.installArtifact(exe_main);

    // Define the windowTest executable
    const exe_windowhandle = b.addExecutable(.{
        .name = "windowTest",
        .root_source_file = b.path("window/winHandle.zig"),
        .target = target,
        .optimize = optimize,
    });

     // Specify package directly in the executable
    const win32_module: *std.Build.Module = b.addModule("win32", .{
        .root_source_file = b.path("libraries/zigwin32/win32.zig"),});
    // Link system libraries for windowTest
    exe_windowhandle.root_module.addImport("win32", win32_module);




    // Install the windowTest executable
    b.installArtifact(exe_windowhandle);

    // Step to run the gameEngine executable
    const run_gameEngine = b.step("run_gameEngine", "Run the gameEngine executable");
    run_gameEngine.dependOn(&exe_main.step);

    // Step to run the windowTest executable
    const run_windowTest = b.step("run_windowTest", "Run the windowTest executable");
    run_windowTest.dependOn(&exe_windowhandle.step);
}
