const std = @import("std");

pub fn build(b: *std.Build) void {
    const target_kernel = b.resolveTargetQuery(.{
        .cpu_arch = .x86,
        .os_tag = .freestanding,
        .abi = .none,
    });
    const optimize = b.standardOptimizeOption(.{});

    const kernel_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target_kernel,
        .optimize = optimize,
        .code_model = .kernel,
    });

    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_module = kernel_module,
    });
    kernel.setLinkerScript(b.path("linker.ld"));

    b.installArtifact(kernel);

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.step);

    const iso_dir = b.fmt("{s}", .{b.exe_dir});
    const iso_path = b.fmt("{s}/ratiOS.iso", .{b.exe_dir});
    const kernel_path = b.fmt("{s}/kernel.elf", .{b.exe_dir});

    const iso_cmd_str = &[_][]const u8{ "/bin/bash", "-c", std.mem.concat(b.allocator, u8, &[_][]const u8{
        "sleep 1 && ",
        "mkdir -p ",
        iso_dir,
        "/boot/grub && ",
        "mv ",
        kernel_path,
        " ",
        iso_dir,
        "/boot/ && ",
        "cp src/grub.cfg ",
        iso_dir,
        "/boot/grub/ && ",
        "grub-mkrescue -o ",
        iso_path,
        " ",
        iso_dir,
    }) catch unreachable };

    const iso_cmd = b.addSystemCommand(iso_cmd_str);
    iso_cmd.step.dependOn(kernel_step);

    const iso_step = b.step("iso", "Build an ISO image");
    iso_step.dependOn(&iso_cmd.step);
    b.default_step.dependOn(iso_step);

    const run_cmd_str = &[_][]const u8{ "qemu-system-i386", "-cdrom", iso_path };
    const run_cmd = b.addSystemCommand(run_cmd_str);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the kernel");
    run_step.dependOn(&run_cmd.step);

    const run_debug_cmd_str = &[_][]const u8{ "qemu-system-i386", "-s", "-S", "-cdrom", iso_path };
    const run_debug_cmd = b.addSystemCommand(run_debug_cmd_str);
    run_debug_cmd.step.dependOn(b.getInstallStep());
    const run_debug_step = b.step("run-debug", "Run the kernel in a debug session");
    run_debug_step.dependOn(&run_debug_cmd.step);

    // Host tests
    const tests_module = b.createModule(.{
        .root_source_file = b.path("tests/host_tests.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = optimize,
    });
    const tests = b.addTest(.{
        .root_module = tests_module,
    });

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run host unit tests");
    test_step.dependOn(&run_tests.step);
}
