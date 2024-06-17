const kernel = @import("kernel");

pub const Color = enum(u8)
{
    BLACK = 0,
    BLUE = 1,
    GREEN = 2,
    CYAN = 3,
    RED = 4,
    MAGENTA = 5,
    BROWN = 6,
    LIGHT_GREY = 7,
    DARK_GREY = 8,
    LIGHT_BLUE = 9,
    LIGHT_GREEN = 10,
    LIGHT_CYAN = 11,
    LIGHT_RED = 12,
    LIGHT_MAGENTA = 13,
    LIGHT_BROWN = 14,
    WHITE = 15,
};

const Screen = struct
{
    row: usize,
    column: usize,
    color: u8,
	var buffer = [2000]u16;
};

const VGA = struct
{
    height: usize = 25,
    width: usize = 80,
    row: usize,
    column: usize,
    color: u8,
    buffer: [*]volatile u16 = @ptrFromInt(0xB8000),
	screensArray: [8]Screen,
	currentScreen: u8,
};

fn computeColor(fg: Color, bg: Color) u8
{
    return @intFromEnum(fg) | @intFromEnum(bg) << 4;
}

fn getVal(uc: u16, color: u16) u16
{
    return uc | color << 8;
}

var vga = VGA
{
    .row = 0,
    .column = 0,
    .color = computeColor(Color.WHITE, Color.BLACK),
	.screensArray =.{.{.row = 0, .column = 0, .color = computeColor(Color.WHITE, Color.BLACK)}} ** 8,
	.currentScreen = 0,
};

pub fn changeScreen(targetScreen: u8) void
{
	if (targetScreen == vga.currentScreen or targetScreen < 0 or targetScreen >= 8)
		return;
	for (vga.buffer, 0..) |val, i|
		vga.screensArray[vga.currentScreen].buffer[i] = val;

	vga.screensArray[vga.currentScreen].row = vga.row;
	vga.screensArray[vga.currentScreen].column = vga.column;
	vga.screensArray[vga.currentScreen].color = vga.color;
	
	for (vga.screensArray[targetScreen].buffer, 0..) |val, i|
		vga.buffer[i] = val;

	vga.row = vga.screensArray[targetScreen].row;
	vga.column = vga.screensArray[targetScreen].column;
	vga.color = vga.screensArray[targetScreen].color;
	vga.currentScreen = targetScreen;

	return;
}

fn putEntry(c: u8, color: u8, x: usize, y: usize) void
{
    vga.buffer[y * vga.width + x] = getVal(c, color);
}

pub fn reverseScroll() void
{
	for (0..(vga.height - 1)) |x|
	{
		for (0..vga.width) |y|
		{
			vga.buffer[x * vga.width + y] = vga.buffer[(x + 1) * vga.width + y];
		}
	}
	for (0..vga.width) |y|
	{
		vga.buffer[y] = 0;
	}
}

pub fn scroll() void
{
	for (1..vga.height) |x|
	{
		for (0..vga.width) |y|
		{
			vga.buffer[(x - 1) * vga.width + y] = vga.buffer[x * vga.width + y];
		}
	}
	for (0..vga.width) |y|
	{
		vga.buffer[vga.height * vga.width + y] = 0;
	}
}

pub fn putChar(c: u8) void
{
    if (c == 0)
        return;
    if (c >= ' ')
        putEntry(c, vga.color, vga.row, vga.column);
    vga.row += 1;
    if (vga.row == vga.width or c == '\n')
    {
        vga.row = 0;
        vga.column += 1;
        if (vga.column == vga.height)
            scroll();
    }
	
}

pub fn putCharAt(c: u8, x: usize, y: usize) void
{
    if(c == 0)
        return;
    vga.buffer[y * vga.width + x] = getVal(c, vga.color);
}

pub fn putString(string: []const u8) void
{
    for (string) |c|
        putChar(c);
}

pub fn setColor(fg: Color, bg: Color) void
{
    vga.color = computeColor(fg, bg);
}

pub fn clear(color: Color) void
{
    for (0..vga.height) |i|
    {
        for (0..vga.width) |j|
            vga.buffer[i * vga.width + j] = getVal(' ', computeColor(Color.WHITE, color));
    }
    vga.column = 0;
    vga.row = 0;
}

pub fn init() void
{
    kernel.logs.klog("[VGA Driver] loading...");
    clear(Color.BLACK);

    kernel.logs.klog("[VGA Driver] loaded");
}
