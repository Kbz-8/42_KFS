const vga = @import("drivers").vga;
const string = @import("../strings/strings.zig");

pub fn kputchar(c: u8) void
{
    vga.putChar(c);
}

pub fn kputs(message: []const u8) void
{
    vga.putString(message);
}

const ArgTypes = enum
{
    Int,
    Hex,
    Bool,
    Float,
    Char,
    String,
    Pointer,
    Null
};

pub fn kprintf(comptime fmt: []const u8, args: anytype) void
{
    comptime var arg_idx: usize = 0;
    comptime var arg_insert: bool = false;
    comptime var arg_type: ArgTypes = .Null;

    inline for(fmt) |c|
    {
        if(c == '{')
        {
            arg_insert = true;
            continue;
        }

        if(arg_insert)
        {
            if(c == '}')
            {
                if(arg_type == .Null)
                {
                    if(@TypeOf(args[arg_idx]) == comptime_int)
                    {
                        if(args[arg_idx] > 0 and args[arg_idx] < 256)
                            vga.putChar(args[arg_idx])
                        else
                            kputNb(args[arg_idx]);
                    }
                    else if(@typeInfo(@TypeOf(args[arg_idx])) == .Array and @typeInfo(@TypeOf(args[arg_idx])).Array.child == u8)
                        kputs(args[arg_idx])
                    else if(@typeInfo(@TypeOf(args[arg_idx])) == .Pointer)
                    {
                        const T = @typeInfo(@TypeOf(args[arg_idx])).Pointer;
                        if(T.child == u8)
                        {
                            var i: usize = 0;
                            while(args[arg_idx][i] != 0) : (i += 1)
                                vga.putChar(args[arg_idx][i]);
                        }
                        else if(@typeInfo(T.child) == .Array and @typeInfo(T.child).Array.child == u8)
                            kputs(args[arg_idx])
                        else
                        {
                            kputs("0x");
                            kputs(string.toStringBase(@intFromPtr(args[arg_idx]), 16));
                        }
                    }
                    else switch(@TypeOf(args[arg_idx]))
                    {
                        i8, u8, => vga.putChar(args[arg_idx]),
                        i16, u16, i32, u32, i64, u64, isize, usize => kputNb(args[arg_idx]),
                        f16, f32, f64, comptime_float => {},
                        bool =>
                        {
                            if(args[arg_idx])
                                kputs("true")
                            else
                                kputs("false");
                        },
                        else => @compileError("could not manage auto detected type : " ++ @typeName(@TypeOf(args[arg_idx])) ++ "; please add type identifier between brackets"),
                    }
                }
                switch(arg_type)
                {
                    .Bool =>
                    {
                        if(args[arg_idx])
                            kputs("true")
                        else
                            kputs("false");
                    },
                    .Char => vga.putChar(args[arg_idx]),
                    .Int => kputNb(args[arg_idx]),
                    .Hex => { kputs("0x"); kputs(string.toStringBase(args[arg_idx], 16)); },
                    .Float => {},
                    .String =>
                    {
                        const T = @typeInfo(@TypeOf(args[arg_idx])).Pointer;
                        if(T.child == u8)
                        {
                            var i: usize = 0;
                            while(args[arg_idx][i] != 0) : (i += 1)
                                vga.putChar(args[arg_idx][i]);
                        }
                        else
                            kputs(args[arg_idx]);
                    },
                    .Pointer => { kputs("0x"); kputs(string.toStringBase(@intFromPtr(args[arg_idx]), 16)); },
                    else => {},
                }

                arg_insert = false;
                arg_idx += 1;
                arg_type = .Null;
            }
            else if(arg_type != .Null)
                @compileError("too much type identifiers between the brackets")
            else
            {
                switch(c)
                {
                    'b' => arg_type = .Bool,
                    'c' => arg_type = .Char,
                    'i' => arg_type = .Int,
                    'x' => arg_type = .Hex,
                    'f' => arg_type = .Float,
                    'p' => arg_type = .Pointer,
                    's' => arg_type = .String,

                    else => @compileError("invalid type identifier between the brackets"),
                }
            }
        }
        else
            vga.putChar(c);
    }

    comptime
    {
        if(args.len != arg_idx)
            @compileError("unused arguments");
    }
}

pub fn kputNb(nbr: i64) void
{
    if(nbr <= -2147483648)
        vga.putString("-2147483648")
    else if(nbr >= 2147483647)
        vga.putString("2147483647")
    else if(nbr < 0)
    {
        vga.putChar('-');
        kputNb(-nbr);
    }
    else if(nbr >= 10)
    {
        kputNb(@divFloor(nbr, 10));
        vga.putChar(@intCast(@mod(nbr, 10) + @as(u8, 48)));
    }
    else
        vga.putChar(@intCast(nbr + 48));
}
