const BUFFER_SIZE: usize = 4096;

const Logger = struct
{
    buffer: [BUFFER_SIZE]u8 = undefined,
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
    logger.buffer[logger.current_index] = '\n';
    logger.current_index += 1;
}

pub fn getLogBuffer() *[BUFFER_SIZE]u8
{
    return &logger.buffer;
}

pub fn initLogger() void
{
    @setCold(true);
    for(0..BUFFER_SIZE) |i|
        logger.buffer[i] = 0;
}
