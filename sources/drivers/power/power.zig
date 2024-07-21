const kernel = @import("kernel");
const acpi = @import("acpi.zig");

pub fn init() void
{
    @setCold(true);
    kernel.logs.klogln("[Power Driver] loading...");
    kernel.logs.beginSection();
    //if(!acpi.init())
    if(true)
    {
        kernel.logs.endSection();
        kernel.logs.klogln("[Power Driver] couldn't load");
    }
    else
    {
        kernel.logs.endSection();
        kernel.logs.klogln("[Power Driver] loaded");
    }
}

pub fn shutdown() void
{
    // qemu shutdown; TODO : fix ACPI
    kernel.arch.ports.out(u16, 0x604, 0x2000);
    //acpi.powerOff();
}

pub fn reboot() void
{
}
