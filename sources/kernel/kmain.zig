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
const libk = @import("libk");

pub const boot = @import("boot.zig");
pub const logs = @import("log.zig");
pub const kpanic = @import("panic.zig").kpanic;

pub const arch = if(!is_test) switch(builtin.cpu.arch)
{
    .x86 => @import("arch/x86/arch.zig"),
    else => unreachable,
} else unreachable;

export fn kmain() void
{
    @setCold(true);
    drivers.initDrivers();
    logs.klogln("Welcome to RatiOS !");
    drivers.shutdownDrivers();
}
