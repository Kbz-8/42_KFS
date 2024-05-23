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
    const vga_buffer: [*]u16 = @ptrFromInt(0xB8000);
    vga_buffer[0] = '4';
    vga_buffer[1] = '2';
}
