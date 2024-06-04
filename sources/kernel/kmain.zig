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

const vga = @import("drivers").vga;

export fn kmain() void
{
	vga.vgaInit();
}
