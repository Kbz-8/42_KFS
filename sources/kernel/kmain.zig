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
const io = @import("io/io.zig");
const kpanic = @import("panic.zig").kpanic;

export fn kmain() void
{
    drivers.initDrivers();
    io.out.kprintf("test {} yipi, {}", .{ 'a', 42 });
    kpanic("test");
    drivers.shutdownDrivers();
}
