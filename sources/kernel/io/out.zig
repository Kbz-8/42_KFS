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

pub fn kprintf(fmt: [*:0]const u8, ...) callconv(.C) c_int
{
    var ap = @cVaStart();
    defer @cVaEnd(&ap);

    var arg_insert: bool = false;
    var arg_type: ArgTypes = .Null;
    var number_char_printed: i32 = 0;

    var i: usize = 0;
    while(fmt[i] != 0)
    {
        if(fmt[i] == '{')
        {
            arg_insert = true;
            i += 1;
            continue;
        }

        if(arg_insert)
        {
            if(fmt[i] == '}')
            {
                if(arg_type == .Null)
                    return -1;

                switch(arg_type)
                {
                    ArgTypes.Char =>
                    {
                        vga.putChar(@cVaArg(&ap, u8));
                        number_char_printed += 1;
                    },
                    ArgTypes.Int => number_char_printed += putNb(@cVaArg(&ap, i32)),
                    ArgTypes.Float => _ = @cVaArg(&ap, f32),
                    ArgTypes.String => _ = @cVaArg(&ap, *u8),
                    ArgTypes.Pointer => _ = @cVaArg(&ap, *u32),
                    else => {},
                }

                arg_insert = false;
                arg_type = .Null;
            }
            else if(arg_type != .Null)
                return -1
            else
            {
                switch(fmt[i])
                {
                    'c' => arg_type = .Char,
                    'i' => arg_type = .Int,
                    'f' => arg_type = .Float,
                    'p' => arg_type = .Pointer,
                    's' => arg_type = .String,

                    else => return -1,
                }
            }
        }
        else
        {
            vga.putChar(fmt[i]);
            number_char_printed += 1;
        }
        i += 1;
    }
    return number_char_printed;
}

pub fn putNb(nbr: i64) i32
{
    var print_size: i32 = 0;

    if(nbr <= -2147483648)
    {
        vga.putString("-2147483648");
        return 11;
    }
    else if(nbr >= 2147483647)
    {
        vga.putString("2147483647");
        return 10;
    }
    else if(nbr < 0)
    {
        vga.putChar('-');
        print_size += putNb(-nbr);
    }
    else if(nbr >= 10)
    {
        print_size += putNb(@divFloor(nbr, 10));
        vga.putChar(@intCast(@mod(nbr, 10) + @as(u8, 48)));
        print_size += 1;
    }
    else
    {
        vga.putChar(@intCast(nbr + 48));
        print_size += 1;
    }
    return print_size;
}
