pub const vga = @import("vga/vga.zig");
pub const keyboard = @import("keyboard/keyboard.zig");

pub fn initDrivers() void
{
	 vga.vgaInit();
}

pub fn shutdownDrivers() void
{

}
