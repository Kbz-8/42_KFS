const vga = @import("drivers").vga;

pub fn kpanic(message: []const u8) noreturn
{
	@setCold(true);
	vga.clear(vga.Color.RED);
	vga.putString("kernel panic !!!");
        vga.putString(message);
	while(true){}
}
