const builtin = @import("builtin");
const is_test = builtin.is_test;

comptime {
    if (!is_test) {
        switch (builtin.cpu.arch) {
            .i386 => _ = @import("Arch/x86/boot.zig"),
            else => unreachable,
        }
    }
}

export fn kmain() void {
    const vga_buffer = @intToPtr([*]volatile u16, 0xB8000);
    inline for ("Hello, world") |byte, i|
        vga_buffer[i] = 0xF0 << 8 | @as(u16, byte);
}
