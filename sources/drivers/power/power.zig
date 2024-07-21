const kernel = @import("kernel");
const acpi = @import("acpi.zig");

pub fn init() void
{
    @setCold(true);
    kernel.logs.klogln("[Power Driver] loading...");
    kernel.logs.beginSection();
    if(!acpi.init())
    //if(true)
    {
        kernel.logs.endSection();
        kernel.logs.klogln("[Power Driver] couldn't load");
    }
    else
    {
        _ = acpi.enable();
        kernel.logs.endSection();
        kernel.logs.klogln("[Power Driver] loaded");
    }
}

pub fn shutdown() void
{
    acpi.powerOff();

    // use QEMU shutdown in case ACPI did not work
    kernel.arch.ports.out(u16, 0x604, 0x2000);
}

pub fn reboot() void
{
    var good: u8 = 0x02;
    while(good & 0x02 != 0)
        good = kernel.arch.ports.in(u8, 0x64);
    kernel.arch.ports.out(u8, 0x64, 0xFE);
    kernel.arch.halt();
}
