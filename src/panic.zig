const kprint = @import("kstd/kprint.zig");
const hal = @import("hal/hal.zig");

pub fn panic(msg: []const u8) noreturn {
    _ = hal.setVideoMode(.vga_text_80x25) catch {};
    kprint.println("\nkernel panic: {s}", .{msg});
    kprint.println("[cannot recover, freezing the system]", .{});
    while (true)
        hal.halt();
}
