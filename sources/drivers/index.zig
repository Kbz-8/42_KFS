pub const vga = @import("vga/vga.zig");
pub const kb = @import("keyboard/keyboard.zig");

const kernel = @import("kernel");

pub fn initDrivers() void
{
    @setCold(true);
    kernel.logs.klog("[Drivers Manager] loading drivers...");
    kb.init();
    kernel.logs.klog("[Drivers Manager] loaded all drivers");
}

pub fn shutdownDrivers() void
{
    @setCold(true);
    kernel.logs.klog("[Drivers Manager] unloading drivers...");
    kernel.logs.klog("[Drivers Manager] unloaded all drivers");
}
