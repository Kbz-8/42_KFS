const kernel = @import("kernel");
const acpi = @import("acpi.zig");

pub fn init() void
{
    @setCold(true);
    kernel.logs.klogln("[Power Driver] loading...");
    if(!acpi.init())
        kernel.logs.klogln("[Power Driver] couldn't load")
    else
        kernel.logs.klogln("[Power Driver] loaded");
}

pub fn shutdown() void
{
    //kernel.arch.ports.out(u16, 0x604, 0x2000);
    acpi.powerOff();
}

pub fn reboot() void
{
}
