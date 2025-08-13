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

const multiboot = @import("../../boot/multiboot.zig");
const boot = @import("../../kernel/bootinfo.zig");
const gdt = @import("gdt.zig");
const idt = @import("idt.zig");

pub export var kernel_stack: [32 * 1024]u8 align(16) linksection(".bss") = undefined;
pub export var user_stack: [64 * 1024]u8 align(16) linksection(".bss") = undefined;

extern fn kmain(boot_infos: *const boot.BootInfos) void;

export fn _start() align(16) linksection(".text.boot") callconv(.naked) noreturn {
    // Get multiboot info address
    const multiboot_info_addr: u32 = asm (
        \\ mov %%ebx, %[res]
        : [res] "=r" (-> u32),
    );
    // Setup the stack and boostrap x86
    asm volatile (
        \\ movl %[stk], %esp
        \\ xor %ebp, %ebp
        \\ push %[mbi]    // <-- pass arg on the stack for .c callconv
        \\ call *%[x86Bootstrap]
        \\ add  $4, %%esp // clean up the pushed arg
        :
        : [stk] "{ecx}" (@intFromPtr(&kernel_stack) + @sizeOf(@TypeOf(kernel_stack))),
          [mbi] "r" (multiboot_info_addr),
          [x86Bootstrap] "r" (&x86Bootstrap),
        : .{ .memory = true });

    while (true)
        asm volatile ("hlt");
}

fn x86Bootstrap(multiboot_info_addr: u32) callconv(.c) void {
    gdt.gdtInit();

    var boot_infos: boot.BootInfos = .{};
    multiboot.populateBootInfos(&boot_infos, @ptrFromInt(multiboot_info_addr));

    idt.idtInit();

    kmain(&boot_infos);
}
