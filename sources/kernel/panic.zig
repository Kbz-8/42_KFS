const vga = @import("drivers").vga;
const arch = @import("kmain.zig").arch;
const logs = @import("log.zig");

pub fn kpanic(message: []const u8) noreturn
{
    @setCold(true);
    vga.setColor(vga.Color.WHITE, vga.Color.RED);
    vga.clear(vga.Color.RED);
    vga.putString(logs.getLogBuffer());
    vga.putString("\nkernel panic : ");
    vga.putString(message);
    while(true)
    {
        arch.disableInts();
        arch.halt();
    }
}
