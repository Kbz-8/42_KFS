const builtin = @import("builtin");
const is_test = builtin.is_test;

comptime
{
    if(!is_test)
    {
        switch(builtin.cpu.arch)
        {
            .x86 => _ = @import("arch/x86/boot.zig"),
            else => unreachable,
        }
    }
}

const drivers = @import("drivers");

pub const logs = @import("log.zig");
pub const kpanic = @import("panic.zig").kpanic;
pub const console = @import("io/out.zig");
pub const ports = @import("ports/ports.zig");
pub const idt = @import("interrupts/idt.zig");
pub const gdt = @import("interrupts/gdt.zig");

export fn kmain() void
{
    @setCold(true);
    // int.init();
    drivers.initDrivers();
    gdt.GDT_Init();
    idt.IDT_Init();
    drivers.kb.init();
    console.kputs("Welcome to RatiOS ! (just to respect the kfs-1 subject : 42)");
    drivers.shutdownDrivers();
}
