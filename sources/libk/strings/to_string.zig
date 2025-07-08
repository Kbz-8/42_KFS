const kernel = @import("kernel");

fn countDigitsInBase(number: i64, base: u8) u8 {
    var count: u8 = 0;
    var tmp: i64 = number;
    while (tmp > 0) {
        tmp = @divFloor(tmp, base);
        count += 1;
    }
    return count;
}

pub fn toStringBufferBase(buffer: []u8, value: anytype, base: u8) ![]u8 {
    switch (@TypeOf(value)) {
        i8, u8, i16, u16, i32, u32, i64, u64, isize, usize, comptime_int => {
            const digits_count = countDigitsInBase(value, base);
            if (digits_count > buffer.len)
                return error.NotEnoughPlace;
            var i: usize = digits_count;
            if (value == 0) {
                buffer[0] = '0';
                return buffer;
            }
            var v = value;
            while (i > 0) : (i -= 1) {
                if (@mod(v, base) > 9)
                    buffer[i] = @truncate((@mod(v, base) - 10) + 'a')
                else
                    buffer[i] = @truncate(@mod(v, base) + '0');
                v = @divFloor(v, base);
            }
        },
        f16, f32, f64, comptime_float => {},
        else => @compileError("could not manage type : " ++ @typeName(@TypeOf(value))),
    }
    return buffer;
}

pub fn toStringBuffer(buffer: []u8, value: anytype) ![]u8 {
    return try toStringBufferBase(buffer, value, 10);
}

pub fn toStringBase(value: anytype, base: u8) []const u8 {
    switch (@TypeOf(value)) {
        i8, u8, i16, u16, i32, u32, i64, u64, isize, usize, comptime_int => {
            const buffer: [22]u8 = [_]u8{0} ** 22;
            return toStringBufferBase(@constCast(buffer[0..buffer.len]), value, base) catch |err| switch (err) {
                error.NotEnoughPlace => return "",
                else => unreachable,
            };
        },
        f16, f32, f64, comptime_float => {},
        else => @compileError("could not manage type : " ++ @typeName(@TypeOf(value))),
    }
    return "";
}

pub fn toString(value: anytype) []const u8 {
    return toStringBase(value, 10);
}
