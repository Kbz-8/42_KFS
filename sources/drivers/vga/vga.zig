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

const VGA = struct
{
    height: usize = 25,
    width: usize = 80,
    row: usize,
    column: usize,
    color: u8,
    buffer: [*]volatile u16 = @ptrFromInt(0xB8000),
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
};

fn putEntry(c: u8, color: u8, x: usize, y: usize) void
{
    vga.buffer[y * vga.width + x] = getVal(c, color);
}

pub fn putChar(c: u8) void
{
    if(c == 0)
        return;
    if(c >= ' ')
        putEntry(c, vga.color, vga.row, vga.column);
    vga.row += 1;
    if(vga.row == vga.width or c == '\n')
    {
        vga.row = 0;
        vga.column += 1;
        if(vga.column == vga.height)
            vga.column = 0;
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
