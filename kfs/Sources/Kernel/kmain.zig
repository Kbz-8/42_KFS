const builtin = @import("builtin");
const is_test = builtin.is_test;

comptime {
    if (!is_test) {
        switch (builtin.cpu.arch) {
            .x86 => _ = @import("Arch/x86/boot.zig"),
            else => unreachable,
        }
    }
}

export fn kmain() void {
    const vga_buffer: [*]volatile u16 = @ptrFromInt(0xB8000);
    vga_buffer[0] = 0xF0 << 8 | @as(u16, '4');
    vga_buffer[1] = 0xF0 << 8 | @as(u16, '2');
}
