pub const vga = @import("vga/vga.zig");
pub const kb = @import("keyboard/keyboard.zig");
pub const power = @import("power/power.zig");

const kernel = @import("kernel");

pub fn initDrivers() void
{
    @setCold(true);
    kernel.logs.klogln("[Drivers Manager] loading drivers...");
    kernel.logs.beginSection();
    kb.init();
    vga.init("RatiOS 0.2", vga.computeColor(vga.Color.BLACK, vga.Color.LIGHT_GREY), vga.computeColor(vga.Color.WHITE, vga.Color.DARK_GREY), vga.computeColor(vga.Color.LIGHT_BLUE, vga.Color.DARK_GREY));
    power.init();
    kernel.logs.endSection();
    kernel.logs.klogln("[Drivers Manager] loaded drivers");
}

pub fn shutdownDrivers() void
{
    @setCold(true);
    kernel.logs.klog("[Drivers Manager] unloading drivers...");
    kernel.logs.klog("[Drivers Manager] unloaded all drivers");
}
