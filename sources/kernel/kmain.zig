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
pub const out = @import("io/out.zig");

export fn kmain() void
{
    @setCold(true);
    logs.initLogger();
    drivers.initDrivers();
    out.kputs("Welcome to RatiOS ! (just to respect the kfs-1 subject : 42)");
    //kpanic("test");
    drivers.shutdownDrivers();
}
