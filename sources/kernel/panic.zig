const vga = @import("drivers").vga;

pub fn kpanic(message: []const u8) noreturn
{
	@setCold(true);
        vga.setColor(vga.Color.WHITE, vga.Color.RED);
	vga.clear(vga.Color.RED);
        vga.putString(message);
	vga.putString(" | kernel panic !!!");
	while(true){}
}
