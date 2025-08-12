const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MAGIC = 0x1BADB002;
const FLAGS = ALIGN | MEMINFO;

const MultibootHeader = packed struct {
    magic: i32 = MAGIC,
    flags: i32,
    checksum: i32,
    padding: u32 = 0,
};

export var _: MultibootHeader align(4) linksection(".multiboot") = .{
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

const multiboot = @import("multiboot.zig");
const boot = @import("../../boot.zig");

pub export var kernel_stack: [32 * 1024]u8 align(16) linksection(".bss") = undefined;
pub export var user_stack: [64 * 1024]u8 align(16) linksection(".bss") = undefined;

var multiboot_info_addr: u32 = 0;

export fn _start() align(16) linksection(".text.boot") callconv(.naked) noreturn {
    // Get multiboot info address
    multiboot_info_addr = asm (
        \\ mov %%ebx, %[res]
        : [res] "=r" (-> u32),
    );
    // Setup the stack and call x86 init
    asm volatile (
        \\ movl %[stk], %esp
        \\ xor %ebp, %ebp
        \\ call x86Init
        :
        : [stk] "{ecx}" (@intFromPtr(&kernel_stack) + @sizeOf(@TypeOf(kernel_stack))),
    );
    while (true)
        asm volatile ("hlt");
}

const arch = @import("arch.zig");

extern fn kmain() void;

export fn x86Init() void {
    @branchHint(.cold);
    arch.idt.idtInit();
    arch.gdt.gdtInit();
    multiboot.populateBootData(&boot.kboot_data, @ptrFromInt(multiboot_info_addr));
    kmain();
}
