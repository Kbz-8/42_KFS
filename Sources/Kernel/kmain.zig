const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MAGIC = 0x1BADB002;
const FLAGS = ALIGN | MEMINFO;

const MultiBoot = packed struct {
    magic: i32,
    flags: i32,
    checksum: i32,
};

export var multiboot align(4) linksection(".multiboot") = MultiBoot{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

export var stack: [16 * 1024]u8 align(16) linksection(".bss") = undefined;

export fn _start() callconv(.Naked) noreturn {
    @call(.{ .stack = &stack }, kernel_main, .{});
    while (true)
        asm volatile ("hlt");
}

fn kernel_main() void {
    const vga_buffer: [*]u8 = @ptrFromInt(0xB8000);
    vga_buffer[0] = '4';
    vga_buffer[1] = '2';
}
