const vga = @import("drivers").vga;
const arch = @import("kmain.zig").arch;
const logs = @import("log.zig");
const stk = @import("debug/stack_trace.zig");

pub fn kpanic(message: []const u8) noreturn
{
    @setCold(true);
    vga.setColor(vga.Color.WHITE, vga.Color.RED);
    vga.clear(vga.Color.RED);
    vga.putString(logs.getLogBuffer());
    stk.stackTrace(4);
    vga.putString("\nkernel panic : ");
    vga.putString(message);
    vga.putString("\n[cannot recover, freezing the system]");
    while(true)
    {
        arch.disableInts();
        arch.halt();
    }
}
