const std = @import("std");

pub fn build(b: *std.Build) void {
    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = .{ .path = "Sources/Kernel/kmain.zig" },
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .x86,
            .abi = .none,
            .os_tag = .freestanding,
        }),
        .optimize = b.standardOptimizeOption(.{}),
    });
    kernel.setLinkerScriptPath(.{ .path = "linker.ld" });
    b.installArtifact(kernel);

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.step);

    const iso_dir = b.fmt("{s}/", .{b.exe_dir});
    const kernel_path = b.fmt("{s}/kernel.elf", .{b.exe_dir});
    const iso_path = b.fmt("{s}/disk.iso", .{b.exe_dir});

    const iso_cmd_str = &[_][]const u8{
        "/bin/sh", "-c",
        std.mem.concat(b.allocator, u8, &[_][]const u8{
        "mkdir -p ", iso_dir, "/boot/ && ",
        "cp ", kernel_path, " ", iso_dir, "/boot/ && ",
        "cp Sources/Grub/grub.cfg ", iso_dir, "/boot/ && ",
        "grub-mkrescue -o ", iso_path, " ", iso_dir })
    catch unreachable };

    const iso_cmd = b.addSystemCommand(iso_cmd_str);
    iso_cmd.step.dependOn(kernel_step);

    const iso_step = b.step("iso", "Build an ISO image");
    iso_step.dependOn(&iso_cmd.step);
    b.default_step.dependOn(iso_step);

    const run_cmd_str = &[_][]const u8{ "qemu-system-i386", "-cdrom", iso_path, "-machine", "type=pc-i440fx-3.1" };

    const run_cmd = b.addSystemCommand(run_cmd_str);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the kernel");
    run_step.dependOn(&run_cmd.step);
}
