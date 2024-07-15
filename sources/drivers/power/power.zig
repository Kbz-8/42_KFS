const kernel = @import("kernel");
const acpi = @import("acpi.zig");

pub fn init() void
{
    @setCold(true);
    kernel.logs.klog("[Power Driver] loading...");
    if(!acpi.init())
        kernel.logs.klog("[Power Driver] couldn't load")
    else
        kernel.logs.klog("[Power Driver] loaded");
}

pub fn shutdown() void
{
    //kernel.arch.ports.out(u16, 0x604, 0x2000);
    acpi.powerOff();
}

pub fn reboot() void
{
}
