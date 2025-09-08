const registry = @import("../registry.zig");
const kprint = @import("../../kstd/kprint.zig");
const hal = @import("../../hal/hal.zig");

const VGA_WIDTH: usize = 80;
const VGA_HEIGHT: usize = 25;
const VGA_PHYS: usize = 0xB8000;

var col: usize = 0;
var row: usize = 0;
var attr: u8 = 0x07; // light gray on black
var buf: [*]volatile u16 = @ptrFromInt(VGA_PHYS);

inline fn makeEntry(ch: u8, a: u8) u16 {
    return @as(u16, ch) | (@as(u16, a) << 8);
}

fn clearScreen() void {
    const blank = makeEntry(' ', attr);
    var i: usize = 0;
    while (i < VGA_WIDTH * VGA_HEIGHT) : (i += 1) buf[i] = blank;
    col = 0;
    row = 0;
}

fn scrollIfNeeded() void {
    if (row < VGA_HEIGHT)
        return;
    // Move rows up by one
    var r: usize = 1;
    while (r < VGA_HEIGHT) : (r += 1) {
        var c: usize = 0;
        while (c < VGA_WIDTH) : (c += 1) {
            buf[(r - 1) * VGA_WIDTH + c] = buf[r * VGA_WIDTH + c];
        }
    }
    // Clear last line
    const blank = makeEntry(' ', attr);
    var c2: usize = 0;
    while (c2 < VGA_WIDTH) : (c2 += 1) buf[(VGA_HEIGHT - 1) * VGA_WIDTH + c2] = blank;
    row = VGA_HEIGHT - 1;
}

fn putByte(b: u8) void {
    switch (b) {
        '\n' => {
            col = 0;
            row += 1;
        },
        '\r' => {
            col = 0;
        },
        '\t' => {
            var i: u8 = 0;
            while (i < 4) : (i += 1) putByte(' ');
        },
        else => {
            buf[row * VGA_WIDTH + col] = makeEntry(b, attr);
            col += 1;
            if (col >= VGA_WIDTH) {
                col = 0;
                row += 1;
            }
        },
    }
    scrollIfNeeded();
}

fn vgaWrite(_: ?*anyopaque, bytes: []const u8) !usize {
    for (bytes) |b|
        putByte(b);
    return bytes.len;
}

fn probe(_: *registry.Device) bool {
    return true; // always available
}

fn attach(_: *registry.Device) void {
    // Try to select VGA text mode as our video backend (non-fatal if not supported)
    _ = hal.setVideoMode(.vga_text_80x25) catch {};
    clearScreen();
    kprint.addSink(.{ .writeFn = vgaWrite, .ctx = null });
    kprint.println("[vga] VGA text console ready", .{});
}

pub const DRIVER = registry.DriverVTable{
    .name = "vga_text",
    .probe = probe,
    .attach = attach,
};
