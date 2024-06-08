const vga = @import("drivers").vga;

pub fn kputs(message: []const u8) void
{
    vga.putString(message);
}

const ArgTypes = enum
{
    Int,
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
                    @compileError("invalid type identifier between the brackets");
                printArg(args[arg_idx], arg_type);

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
                    'c' => arg_type = .Char,
                    'i' => arg_type = .Int,
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

fn printArg(arg: anytype, T: ArgTypes) void
{
    switch(T)
    {
        .Char => vga.putChar(arg),
        .Int => putNb(arg),
        .Float => {},
        .String => {},
        .Pointer => {},
        else => {},
    }
}

fn putNb(nbr: i64) void
{
    if(nbr <= -2147483648)
        vga.putString("-2147483648")
    else if(nbr >= 2147483647)
        vga.putString("2147483647")
    else if(nbr < 0)
    {
        vga.putChar('-');
        putNb(-nbr);
    }
    else if(nbr >= 10)
    {
        putNb(@divFloor(nbr, 10));
        vga.putChar(@intCast(@mod(nbr, 10) + @as(u8, 48)));
    }
    else
        vga.putChar(@intCast(nbr + 48));
}
