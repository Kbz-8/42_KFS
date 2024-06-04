pub const vga = @import("vga/vga.zig");

pub fn initDrivers() void
{
	 vga.vgaInit();
}

pub fn shutdownDrivers() void
{

}
