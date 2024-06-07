//comptime
//{
//    asm (
//        \\ .set ALIGN,    1 << 0
//        \\ .set MEMINFO,  1 << 1
//        \\ .set FLAGS,    ALIGN | MEMINFO
//        \\ .set MAGIC,    0x1BADB002
//        \\ .set CHECKSUM, -(MAGIC + FLAGS)
//        \\
//        \\ .section .multiboot
//        \\ .align 4
//        \\ .long MAGIC
//        \\ .long FLAGS
//        \\ .long CHECKSUM
//    );
//}

const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MAGIC = 0x1BADB002;
const FLAGS = ALIGN | MEMINFO;

const MultiBoot = packed struct
{
    magic: i32 = MAGIC,
    flags: i32,
    checksum: i32,
    _: i32 = 0,
};

export var multiboot align(4) linksection(".multiboot") = MultiBoot
{
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

export var kernel_stack: [32 * 1024]u8 align(16) linksection(".bss") = undefined;

extern fn kmain() void;

export fn _start() align(16) linksection(".text.boot") callconv(.Naked) noreturn
{
    // Setup the stack and call kernel
    asm volatile (
        \\ movl %[stk], %esp
        \\ call kmain
        :
        : [stk] "{ecx}" (@intFromPtr(&kernel_stack) + @sizeOf(@TypeOf(kernel_stack))),
    );
    while(true) {}
}
