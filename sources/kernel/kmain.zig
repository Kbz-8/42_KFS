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
pub const arch = if(!is_test) switch(builtin.cpu.arch)
{
    .x86 => @import("arch/x86/arch.zig"),
    else => unreachable,
};

export fn kmain() void
{
    @setCold(true);
    drivers.vga.clear(drivers.vga.Color.BLACK);
    arch.init();
    drivers.initDrivers();
    drivers.shutdownDrivers();
}
