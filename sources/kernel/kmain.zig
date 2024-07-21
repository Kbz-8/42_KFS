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

const shell = @import("shell/dumb_shell.zig");

var sh: shell.DumbShell = .{};

fn screensWatcher(screen: u8) void
{
    if(screen == 0)
        sh.run()
    else
        sh.pause();
}

export fn kmain() void
{
    @setCold(true);
    drivers.initDrivers();
    logs.klogln("Welcome to RatiOS !");
    drivers.vga.installScreenWatcher(screensWatcher);
    sh.launch();
    drivers.shutdownDrivers();
    drivers.power.shutdown();
}
