const std = @import("std");

pub fn build(b: *std.Build) void {
    const os = b.addExecutable(.{
        .name = "image.elf",
        .root_source_file = .{ .path = "Sources/Kernel/kmain.zig" },
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .x86,
            .os_tag = .freestanding,
        }),
        .optimize = b.standardOptimizeOption(.{}),
    });
    os.setLinkerScriptPath(.{ .path = "linker.ld" });
    b.installArtifact(os);

    const run_cmd = b.addSystemCommand(&.{ "qemu-system-i386", "-kernel", "zig-out/bin/image.elf", "-display", "sdl" });

    const run_step = b.step("run", "Run the os");
    run_step.dependOn(&run_cmd.step);
}
