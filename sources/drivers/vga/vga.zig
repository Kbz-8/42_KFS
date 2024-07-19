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
    row: usize = 0,
    column: usize = 1,
    curr_bg : Color = Color.BLACK,
    curr_fg : Color = Color.WHITE,
    color: u8 = computeColor(Color.WHITE, Color.BLACK),
    buffer : [2000]u16 = [_]u16{getVal(' ', computeColor(Color.WHITE, Color.BLACK))} ** 2000,
};

const VGA = struct
{
    height: usize = 25,
    width: usize = 80,
    row: usize,
    column: usize,
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
    .row = 0,
    .column = 1,
    .color = computeColor(Color.WHITE, Color.BLACK),
    .nav_triggered_color = 0,
    .nav_color = 0,
    .screensArray = [_]Screen{.{}} ** 8,
    .currentScreen = 0,
};

fn updateCursor() void
{
    const pos : u32 = vga.column * vga.width + @as(u16, @truncate(vga.row));

    kernel.arch.ports.out(u8, 0x3D4, 0x0F);
    kernel.arch.ports.out(u8, 0x3D5, @as(u8, @truncate(pos)) & 0xFF);
    kernel.arch.ports.out(u8, 0x3D4, 0x0E);
    kernel.arch.ports.out(u8, 0x3D5, @as(u8, @truncate(pos >> 8)) & 0xFF);
}

pub fn changeScreen(targetScreen: u8) void
{
    if(targetScreen == vga.currentScreen or targetScreen < 0 or targetScreen >= 8)
        return;
    for (vga.buffer, 0..2000) |val, i|
        vga.screensArray[vga.currentScreen].buffer[i] = val;

    vga.screensArray[vga.currentScreen].row = vga.row;
    vga.screensArray[vga.currentScreen].column = vga.column;
    vga.screensArray[vga.currentScreen].color = vga.color;
    vga.screensArray[vga.currentScreen].curr_bg = vga.curr_bg;
    vga.screensArray[vga.currentScreen].curr_fg = vga.curr_fg;

    for (80..2000) |i|
        vga.buffer[i] = vga.screensArray[targetScreen].buffer[i];

    vga.row = vga.screensArray[targetScreen].row;
    vga.column = vga.screensArray[targetScreen].column;
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
	const values = [_]u8{'1','2','3','4','5','6','S','L'};
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
	// const values = [_]u8{'1','2','3','4','5','6','S','L'};
	// var i : u32 = 63;
	// for (values) |c|
	// {
	// 	putCharAt(' ', i, 0);
	// 	i += 1;
	// 	putCharAt(c, i, 0);
	// 	i += 1;
    // }
    vga.color = computeColor(vga.curr_fg, vga.curr_bg);
    vga.column = 1;
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
    for(0..(vga.height - 2)) |x|
    {
        for(0..vga.width) |y|
            vga.buffer[x * vga.width + y] = vga.buffer[(x + 1) * vga.width + y];
    }
    for(0..vga.width) |y|
        vga.buffer[y] = getVal(' ', vga.color);
    updateCursor();
}

pub fn scroll() void
{
    for(2..vga.height) |x|
    {
        for (0..vga.width) |y|
            vga.buffer[(x - 1) * vga.width + y] = vga.buffer[x * vga.width + y];
    }
    for(0..vga.width) |y|
        vga.buffer[(vga.height - 1) * vga.width + y] = getVal(' ', vga.color);
    vga.column -= 1;
    updateCursor();
}

pub fn putChar(c: u8) void
{
    if(c == 0)
        return;
    if(c >= ' ' and c <= 126)
        putEntry(c, vga.color, vga.row, vga.column);
    if(c == 14)
    {
        if(vga.row == 0 and vga.column <= 1)
            return;
        if(vga.row == 0 and vga.column != 0)
        {
            vga.row = vga.width;
            vga.column -= 1;
            putCharAt(' ', vga.row, vga.column);
            return ;
        }
        vga.row -= 1;
        putCharAt(' ', vga.row, vga.column);
        updateCursor();
        return;
    }
    if(c > 126)
        return;
    vga.row += 1;
    if(vga.row == vga.width or c == '\n')
    {
        vga.row = 0;
        vga.column += 1;
        if(vga.column == vga.height)
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
    vga.column = 0;
    vga.row = 0;
    updateCursor();
}
