const kprint = @import("kstd/kprint.zig");

pub fn panic(msg: []const u8) noreturn {
    kprint.println("kernel panic: {s}", .{msg});
    kprint.println("[cannot recover, freezing the system]", .{});
    while (true)
        asm volatile ("hlt");
}
