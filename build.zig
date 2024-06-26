const std = @import("std");

pub fn build(b: *std.Build) void
{
    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = .{ .path = "sources/kernel/kmain.zig" },
            .target = b.resolveTargetQuery(.{
            .cpu_arch = .x86,
            .abi = .none,
            .os_tag = .freestanding,
        }),
        .optimize = .Debug,
        .strip = true,
        .code_model = .kernel,
        .pic = false,
        .error_tracing = false,
    });
    kernel.setLinkerScriptPath(.{ .path = "linker.ld" });

    const drivers_module = b.addModule("drivers", .{
        .root_source_file = .{ .path = "sources/drivers/index.zig" }
    });

    drivers_module.addImport("kernel", &kernel.root_module);
    kernel.root_module.addImport("drivers", drivers_module);

    b.installArtifact(kernel);

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.step);

    const iso_dir = b.fmt("{s}", .{b.exe_dir});
    const iso_path = b.fmt("{s}/ratiOS.iso", .{b.exe_dir});
    const kernel_path = b.fmt("{s}/kernel.elf", .{b.exe_dir});

    const iso_cmd_str = &[_][]const u8
    {
        "/bin/bash", "-c",
        std.mem.concat(b.allocator, u8, &[_][]const u8
        {
            "mkdir -p ", iso_dir, "/boot/grub && ",
            "mv ", kernel_path, " ", iso_dir, "/boot/ && ",
            "cp sources/grub/grub.cfg ", iso_dir, "/boot/grub/ && ",
            "grub-mkrescue -o ", iso_path, " ", iso_dir
        })
        catch unreachable
    };

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
