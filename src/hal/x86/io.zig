// Minimal port I/O + 16550A UART setup/tx

pub const PortType = enum {
    byte,
    word,
    long,
};

fn uintFor(comptime w: PortType) type {
    return switch (w) {
        .byte => u8,
        .word => u16,
        .long => u32,
    };
}

pub fn in(comptime size: PortType, port: u16) uintFor(type) {
    return switch (size) {
        .byte => asm volatile (
            \\ inb %[port], %[result]
            : [result] "={al}" (-> u8),
            : [port] "N{dx}" (port),
        ),
        .word => asm volatile (
            \\ inw %[port], %[result]
            : [result] "={ax}" (-> u16),
            : [port] "N{dx}" (port),
        ),
        .long => asm volatile (
            \\ inl %[port], %[result]
            : [result] "={eax}" (-> u32),
            : [port] "N{dx}" (port),
        ),
        else => @compileError("invalid data type. Only .byte, .word or .long"),
    };
}

pub fn out(comptime size: PortType, port: u16, data: uintFor(size)) void {
    switch (size) {
        .byte => asm volatile (
            \\ outb %[data], %[port]
            :
            : [port] "{dx}" (port),
              [data] "{al}" (data),
        ),
        .word => asm volatile (
            \\ outw %[data], %[port]
            :
            : [port] "{dx}" (port),
              [data] "{ax}" (data),
        ),
        .long => asm volatile (
            \\ outl %[data], %[port]
            :
            : [port] "{dx}" (port),
              [data] "{eax}" (data),
        ),
        else => @compileError("invalid data type. Only .byte, .word or .long"),
    }
}

const COM1: u16 = 0x3F8;

pub fn serialInit() void {
    // 115200 8N1, enable FIFO
    out(.byte, COM1 + 1, 0x00); // disable interrupts
    out(.byte, COM1 + 3, 0x80); // DLAB on
    out(.byte, COM1 + 0, 0x01); // divisor low (115200)
    out(.byte, COM1 + 1, 0x00); // divisor high
    out(.byte, COM1 + 3, 0x03); // 8N1, DLAB off
    out(.byte, COM1 + 2, 0xC7); // FIFO on, clear, 14-byte threshold
    out(.byte, COM1 + 4, 0x0B); // IRQs enabled, RTS/DSR set
}

inline fn txEmpty() bool {
    return (in(.byte, COM1 + 5) & 0x20) != 0;
}

pub fn serialWriteByte(b: u8) void {
    while (!txEmpty()) {}
    out(.byte, COM1, b);
}
