const fmt = @import("std").fmt;
const Writer = @import("std").io.Writer;

const vga = @import("drivers").vga;

pub const writer = Writer(void, error{}, callback){ .context = {} };

fn callback(_: void, string: []const u8) error{}!usize
{
    vga.putString(string);
    return string.len;
}

pub fn kprintf(comptime format: []const u8, args: anytype) void
{
    fmt.format(writer, format, args) catch unreachable;
}
