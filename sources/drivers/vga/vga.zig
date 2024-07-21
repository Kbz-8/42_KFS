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
    x: usize = 0,
    y: usize = 1,
    curr_bg : Color = Color.BLACK,
    curr_fg : Color = Color.WHITE,
    color: u8 = computeColor(Color.WHITE, Color.BLACK),
    pointer: u16 = 0,
    buffer : [8000]u16 = [_]u16{getVal(' ', computeColor(Color.WHITE, Color.BLACK))} ** 8000,
};

const VGA = struct
{
    height: usize = 25,
    width: usize = 80,
    x: usize,
    y: usize,
    color: u8,
    nav_color : u8,
    nav_triggered_color : u8,
    curr_bg : Color = Color.BLACK,
    curr_fg : Color = Color.WHITE,
    buffer: [*]volatile u16 = @ptrFromInt(0xB8000),
    screensArray: [8]Screen,
    currentScreen: u8,
};

pub fn computeColor(fg: Color, bg: Color) u8
{
    return @intFromEnum(fg) | @intFromEnum(bg) << 4;
}

fn getVal(uc: u16, color: u16) u16
{
    return uc | color << 8;
}

var vga = VGA
{
    .x = 0,
    .y = 1,
    .color = computeColor(Color.WHITE, Color.BLACK),
    .nav_triggered_color = 0,
    .nav_color = 0,
    .screensArray = [_]Screen{.{}} ** 8,
    .currentScreen = 0,
};

fn updateCursor() void
{
    const pos : u32 = vga.y * vga.width + @as(u16, @truncate(vga.x));

    kernel.arch.ports.out(u8, 0x3D4, 0x0F);
    kernel.arch.ports.out(u8, 0x3D5, @as(u8, @truncate(pos)) & 0xFF);
    kernel.arch.ports.out(u8, 0x3D4, 0x0E);
    kernel.arch.ports.out(u8, 0x3D5, @as(u8, @truncate(pos >> 8)) & 0xFF);
}

pub fn changeScreen(targetScreen: u8) void
{
    if(targetScreen == vga.currentScreen or targetScreen < 0 or targetScreen >= 8)
        return;
    for (vga.width..2000) |i|
        vga.screensArray[vga.currentScreen].buffer[vga.screensArray[vga.currentScreen].pointer * vga.width + i] = vga.buffer[i];

    vga.screensArray[vga.currentScreen].x = vga.x;
    vga.screensArray[vga.currentScreen].y = vga.y;
    vga.screensArray[vga.currentScreen].color = vga.color;
    vga.screensArray[vga.currentScreen].curr_bg = vga.curr_bg;
    vga.screensArray[vga.currentScreen].curr_fg = vga.curr_fg;

    for (vga.width..2000) |i|
        vga.buffer[i] = vga.screensArray[targetScreen].buffer[vga.screensArray[targetScreen].pointer * vga.width + i];

    vga.x = vga.screensArray[targetScreen].x;
    vga.y = vga.screensArray[targetScreen].y;
    vga.color = vga.screensArray[targetScreen].color;
    vga.curr_bg = vga.screensArray[targetScreen].curr_bg;
    vga.curr_fg = vga.screensArray[targetScreen].curr_fg;
    vga.currentScreen = targetScreen;
    updateCursor();
    updateNavbar();
}

fn updateNavbar() void
{
    vga.color = vga.nav_color;
    const values = [_]u8{'1','2','3','4','5','6','7','L'};
    var i : u32 = 63;
    for(values) |c|
    {
        putCharAt(' ', i, 0);
        i += 1;
        if(@as(u8, @truncate((i - 63) / 2)) == vga.currentScreen)
        {
            vga.color = vga.nav_triggered_color;
            putCharAt(c, i, 0);
            vga.color = vga.nav_color;
        }
        else
            putCharAt(c, i, 0);
        i += 1;
    }
    putCharAt(' ', i, 0);
    vga.color = computeColor(vga.curr_fg, vga.curr_bg);
}

pub fn moveCursor(dir : u8) void
{
    if (dir == 75 and vga.x > 0)
        vga.x -= 1;
    if (dir == 72 and vga.y > 1)
        vga.y -= 1;
    if (dir == 77 and vga.x < vga.width - 1)
        vga.x += 1;
    if (dir == 80 and vga.y < vga.height)
        vga.y += 1;
    if (dir == 72 and vga.y == 1)
        reverseScroll();
    if (dir == 80 and vga.y == vga.height)
        scroll();
    updateCursor();
}

pub fn init(title : []const u8, title_color : u8, navbar_color : u8, triggered_color : u8) void
{
    kernel.logs.klogln("[VGA Driver] loading...");
    if(title.len >= 48)
        return;
    vga.color = title_color;
    putStringAt(title, 0, 0);
    for(title, 0..title.len) |c, i|
        putCharAt(c, i, 0);
    vga.color = navbar_color;
    for(title.len..48) |i|
        putCharAt(' ', i, 0);
    // Colors gradient for style
    const gradient_values = [_]u8{ 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63 };
    for(gradient_values) |i|
    {
        vga.color = computeColor(@enumFromInt(i - 48), @enumFromInt(i - 48));
        putCharAt(' ', i, 0);
    }
    vga.color = navbar_color;
    vga.nav_color = navbar_color;
    vga.nav_triggered_color = triggered_color;
    vga.color = computeColor(vga.curr_fg, vga.curr_bg);
    vga.y = 1;
    for (80..1999) |i|
        vga.buffer[i] = getVal(' ', computeColor(Color.WHITE, Color.BLACK));
    updateCursor();
    updateNavbar();
    kernel.logs.klogln("[VGA Driver] loaded");
}

fn putEntry(c: u8, color: u8, x: usize, y: usize) void
{
    vga.buffer[y * vga.width + x] = getVal(c, color);
}

pub fn reverseScroll() void
{
	var x : usize = vga.height - 2;
	if (vga.screensArray[vga.currentScreen].pointer == 0)
		return;
	for (0..vga.width) |y|
		vga.screensArray[vga.currentScreen].buffer[(vga.screensArray[vga.currentScreen].pointer + vga.height - 1) * vga.width + y] = vga.buffer[(vga.height - 1) * vga.width + y];
	while (x > 0)
	{
		for(0..(vga.width - 1)) |y|
            vga.buffer[(x + 1) * vga.width + y] = vga.buffer[x * vga.width + y];
		x -= 1;
	}
	for (0..vga.width) |y|
		vga.buffer[vga.width + y] = vga.screensArray[vga.currentScreen].buffer[(vga.screensArray[vga.currentScreen].pointer - 1) * vga.width + y];
	vga.screensArray[vga.currentScreen].pointer -= 1;
	if (vga.y < vga.height) 
		vga.y += 1;
    updateCursor();
}

pub fn scroll() void
{
	if (vga.screensArray[vga.currentScreen].pointer == 75)
		return;
	for (0..vga.width) |y|
		vga.screensArray[vga.currentScreen].buffer[vga.screensArray[vga.currentScreen].pointer * vga.width + y] = vga.buffer[vga.width + y];
    for(2..vga.height) |x|
    {
        for (0..vga.width) |y|
            vga.buffer[(x - 1) * vga.width + y] = vga.buffer[x * vga.width + y];
    }
    for(0..vga.width) |y|
        vga.buffer[(vga.height - 1) * vga.width + y] = vga.screensArray[vga.currentScreen].buffer[(vga.screensArray[vga.currentScreen].pointer + vga.height) * vga.width + y];
	if (vga.y > 1) 
		vga.y -= 1 
	else 
		vga.x = 0;
	vga.screensArray[vga.currentScreen].pointer += 1;
    updateCursor();
}

pub fn backspace() void
{
	if(vga.x == 0 and vga.y <= 1)
        return;
   	if(vga.x == 0 and vga.y != 0)
    {
        vga.x = vga.width - 1;
        vga.y -= 1;
		if (vga.buffer[vga.y * vga.width + vga.x] != getVal(' ', vga.color))
		{
			putCharAt(' ', vga.x, vga.y);
			updateCursor();
    		return;
		}
		while (vga.buffer[vga.y * vga.width + vga.x - 1] == getVal(' ', vga.color) and vga.x > 0)
			vga.x -= 1;
		updateCursor();
        return ;
    }
    vga.x -= 1;
    putCharAt(' ', vga.x, vga.y);
    updateCursor();
    return;
}

pub fn putChar(c: u8) void
{
    if(c == 0)
        return;
    if(c >= ' ' and c <= 126)
        putEntry(c, vga.color, vga.x, vga.y);
    if(c > 126)
        return;
    vga.x += 1;
    if(vga.x == vga.width or c == '\n')
    {
        vga.x = 0;
        vga.y += 1;
        if(vga.y == vga.height)
            scroll();
    }
    updateCursor();
}

pub fn putCharAt(c: u8, x: usize, y: usize) void
{
    if(c == 0)
        return;
    vga.buffer[y * vga.width + x] = getVal(c, vga.color);
}

pub fn putStringAt(string : []const u8, x: usize, y: usize) void
{
    for(string, 0..) |c, i|
        putCharAt(c, x + i, y);
    return;
}

pub fn putString(string: []const u8) void
{
    for(string) |c|
        putChar(c);
}

pub fn setColor(fg: Color, bg: Color) void
{
    vga.color = computeColor(fg, bg);
    vga.curr_fg = fg;
    vga.curr_bg = bg;
}

pub fn clear(color: Color) void
{
    for(0..vga.height) |i|
    {
        for(0..vga.width) |j|
            vga.buffer[i * vga.width + j] = getVal(' ', computeColor(Color.WHITE, color));
    }
    vga.y = 0;
    vga.x = 0;
    updateCursor();
}
