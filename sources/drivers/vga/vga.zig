const vga_buffer: [*]volatile u16 = @ptrFromInt(0xB8000);
    vga_buffer[0] = 0xF0 << 8 | @as(u16, '4');
    vga_buffer[1] = 0xF0 << 8 | @as(u16, '2');

const VGA_COLOR = enum
{
	VGA_COLOR_BLACK = 0,
	VGA_COLOR_BLUE = 1,
	VGA_COLOR_GREEN = 2,
	VGA_COLOR_CYAN = 3,
	VGA_COLOR_RED = 4,
	VGA_COLOR_MAGENTA = 5,
	VGA_COLOR_BROWN = 6,
	VGA_COLOR_LIGHT_GREY = 7,
	VGA_COLOR_DARK_GREY = 8,
	VGA_COLOR_LIGHT_BLUE = 9,
	VGA_COLOR_LIGHT_GREEN = 10,
	VGA_COLOR_LIGHT_CYAN = 11,
	VGA_COLOR_LIGHT_RED = 12,
	VGA_COLOR_LIGHT_MAGENTA = 13,
	VGA_COLOR_LIGHT_BROWN = 14,
	VGA_COLOR_WHITE = 15,
};

const VGA_TERMINAL = struct
{
	VGA_HEIGHT: usize = 25,
	VGA_WIDTH: usize = 80,
	VGA_terminal_row: usize,
	VGA_terminal_column: usize,
	VGA_terminal_color: u8,
	VGA_terminal_buffer: [*]volatile u16 = @ptrFromInt(0xB8000),
}

fn vga_color(fg: VGA_COLOR, bg: VGA_COLOR) u16
{
	return (fg | bg << 4);
}

var vga = VGA_TERMINAL
{
	.VGA_terminal_row = 0;
	.VGA_terminal_column = 0;
	.VGA_terminal_color
};

export fn vgaInit() noreturn
{

}