const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MAGIC = 0x1BADB002;
const FLAGS = ALIGN | MEMINFO;

const MultiBoot = packed struct {
    magic: i32 = MAGIC,
    flags: i32,
    checksum: i32,
};

export var multiboot align(4) linksection(".multiboot") = MultiBoot{
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

export var kernel_stack: [16 * 1024]u8 align(16) linksection(".bss") = undefined;

extern fn kmain() void;

export fn _start() align(16) linksection(".text.boot") callconv(.Naked) noreturn {
    // Setup the stack
    asm volatile (
        \\.extern KERNEL_STACK_END
        \\mov $KERNEL_STACK_END, %%esp
        \\sub $32, %%esp
        \\mov %%esp, %%ebp
    );
    kmain();
    while (true) {}
}
