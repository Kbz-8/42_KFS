const BUFFER_SIZE: usize = 4096;

const Logger = struct
{
    buffer: [BUFFER_SIZE]u8 = .{0} ** BUFFER_SIZE,
    current_index: usize = 0,

    fn shiftBuffer(self: *Logger, size: usize) void
    {
        for(0..BUFFER_SIZE) |i|
        {
            if(i + size < BUFFER_SIZE)
                self.buffer[i] = self.buffer[i + size]
            else
                self.buffer[i] = 0;
        }
    }
};

var logger = Logger{};

pub fn klog(message: []const u8) void
{
    if(message.len + logger.current_index >= BUFFER_SIZE)
    {
        logger.shiftBuffer(message.len + 1);
        logger.current_index -= message.len + 1;
    }

    for(message) |c|
    {
        logger.buffer[logger.current_index] = c;
        logger.current_index += 1;
    }
}

pub fn klogln(message: []const u8) void
{
    klog(message);
    klog("\n");
}

pub fn klogNb(nbr: i64) void
{
    if(nbr <= -2147483648)
        klog("-2147483648")
    else if(nbr >= 2147483647)
        klog("2147483647")
    else if(nbr < 0)
    {
        klog("-");
        klogNb(-nbr);
    }
    else if(nbr >= 10)
    {
        klogNb(@divFloor(nbr, 10));
        const c: [1]u8 = .{ @intCast(@mod(nbr, 10) + @as(u8, 48)) };
        klog(&c);
    }
    else
    {
        const c: [1]u8 = .{ @intCast(nbr + 48) };
        klog(&c);
    }
}

pub fn getLogBuffer() *[BUFFER_SIZE]u8
{
    return &logger.buffer;
}
