pub const ports = @import("ports.zig");
pub const idt = @import("idt.zig");
pub const gdt = @import("gdt.zig");

pub fn halt() void
{
    asm volatile("hlt");
}

pub fn enableInts() void
{
    asm volatile("sti");
}

pub fn disableInts() void
{
    asm volatile("cli");
}

pub fn init() void
{
    gdt.gdtInit();
    idt.idtInit();
}
