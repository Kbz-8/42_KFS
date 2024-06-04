const builtin = @import("builtin");
const is_test = builtin.is_test;

comptime
{
	if(!is_test)
	{
		switch(builtin.cpu.arch)
		{
			.x86 => _ = @import("arch/x86/boot.zig"),
			else => unreachable,
		}
	}
}

const drivers = @import("drivers");

export fn kmain() void
{
	drivers.initDrivers();
	drivers.vga.vgaPutString("caca pipi partout mdr");
	drivers.shutdownDrivers();
}
