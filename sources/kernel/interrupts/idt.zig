pub const out = @import("../io/out.zig");
pub const ports = @import("../ports/ports.zig");
pub const kpanic = @import("../panic.zig").kpanic;

extern fn  isr0()void; extern fn  isr1()void; extern fn  isr2()void; extern fn  isr3()void;
extern fn  isr4()void; extern fn  isr5()void; extern fn  isr6()void; extern fn  isr7()void;
extern fn  isr8()void; extern fn  isr9()void; extern fn isr10()void; extern fn isr11()void;
extern fn isr12()void; extern fn isr13()void; extern fn isr14()void; extern fn isr15()void;
extern fn isr16()void; extern fn isr17()void; extern fn isr18()void; extern fn isr19()void;
extern fn isr20()void; extern fn isr21()void; extern fn isr22()void; extern fn isr23()void;
extern fn isr24()void; extern fn isr25()void; extern fn isr26()void; extern fn isr27()void;
extern fn isr28()void; extern fn isr29()void; extern fn isr30()void; extern fn isr31()void;
extern fn isr32()void; extern fn isr33()void; extern fn isr34()void; extern fn isr35()void;
extern fn isr36()void; extern fn isr37()void; extern fn isr38()void; extern fn isr39()void;
extern fn isr40()void; extern fn isr41()void; extern fn isr42()void; extern fn isr43()void;
extern fn isr44()void; extern fn isr45()void; extern fn isr46()void; extern fn isr47()void;
extern fn isr128()void; extern fn isr177() void;

const IDTEntry = packed struct
{
    base_low: u16,
    segment_selector: u16,
    reserved: u8,
    flags: u8,
    base_high: u16,
};

const IDTPointer = packed struct
{
    limit: u16,
    base: *[256]IDTEntry,
};

pub const IDTRegister = packed struct
{
    cr2: u32,
    ds: u32,
    edi: u32,
    esi: u32,
    ebp: u32,
    esp: u32,
    ebx: u32,
    edx: u32, 
    ecx: u32, 
    eax: u32,
    int_nb: u32,
    errcode: u32,
    eip: u32,
    csm: u32,
    eflags: u32,
    useresp: u32,
    ss: u32,
};

var idt_entries: [256]IDTEntry = undefined;

var idt_pointer = IDTPointer
{
    .limit = 0,
    .base = undefined,
};

var error_messages = [_][] const u8 
{
    "Division By Zero",
    "Debug",
    "Non Maskable Interrupt",
    "Breakpoint",
    "Into Detected Overflow",
    "Out of Bounds",
    "Invalid Opcode",
    "No Coprocessor",
    "Double fault",
    "Coprocessor Segment Overrun",
    "Bad TSS",
    "Segment not present",
    "Stack fault",
    "General protection fault",
    "Page fault",
    "Unknown Interrupt",
    "Coprocessor Fault",
    "Alignment Fault",
    "Machine Check", 
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved"
};


pub fn idtFlush(t: u32) void
{
    asm volatile
    (
        \\ lidt (%%eax)
        \\ sti
        :
        : [t] "{eax}" (t)
        : "memory"
    );
    return;
}

pub fn idtInit() void
{
    out.kputs("INIT\n");
    for (0..255) |i|
    {
        idt_entries[i].base_low = 0;
        idt_entries[i].segment_selector = 0;
        idt_entries[i].reserved = 0;
        idt_entries[i].flags = 0;
        idt_entries[i].base_high = 0;
    }
    idt_pointer.limit = @sizeOf(IDTEntry) * 256 - 1;
    idt_pointer.base = &idt_entries;

    // init "master" chip (commands: 0x20 data: 0x21) and "slave" chip (commands: 0xA0 data: 0xA1)
    ports.out(u8, 0x20, 0x11);
    ports.out(u8, 0xA0, 0x11);

    ports.out(u8, 0x21, 0x20);
    ports.out(u8, 0xA1, 0x28);

    ports.out(u8, 0x21, 0x04);
    ports.out(u8, 0xA1, 0x02);

    ports.out(u8, 0x21, 0x01);
    ports.out(u8, 0xA1, 0x01);

    ports.out(u8, 0x21, 0x00);
    ports.out(u8, 0xA1, 0x00);
    idtSetGate(0,  @intFromPtr(&isr0),  0x08, 0x8E);
    idtSetGate(1,  @intFromPtr(&isr1),  0x08, 0x8E);
    idtSetGate(2,  @intFromPtr(&isr2),  0x08, 0x8E);
    idtSetGate(3,  @intFromPtr(&isr3),  0x08, 0x8E);
    idtSetGate(4,  @intFromPtr(&isr4),  0x08, 0x8E);
    idtSetGate(5,  @intFromPtr(&isr5),  0x08, 0x8E);
    idtSetGate(6,  @intFromPtr(&isr6),  0x08, 0x8E);
    idtSetGate(7,  @intFromPtr(&isr7),  0x08, 0x8E);
    idtSetGate(8,  @intFromPtr(&isr8),  0x08, 0x8E);
    idtSetGate(9,  @intFromPtr(&isr9),  0x08, 0x8E);
    idtSetGate(10, @intFromPtr(&isr10), 0x08, 0x8E);
    idtSetGate(11, @intFromPtr(&isr11), 0x08, 0x8E);
    idtSetGate(12, @intFromPtr(&isr12), 0x08, 0x8E);
    idtSetGate(13, @intFromPtr(&isr13), 0x08, 0x8E);
    idtSetGate(14, @intFromPtr(&isr14), 0x08, 0x8E);
    idtSetGate(15, @intFromPtr(&isr15), 0x08, 0x8E);
    idtSetGate(16, @intFromPtr(&isr16), 0x08, 0x8E);
    idtSetGate(17, @intFromPtr(&isr17), 0x08, 0x8E);
    idtSetGate(18, @intFromPtr(&isr18), 0x08, 0x8E);
    idtSetGate(19, @intFromPtr(&isr19), 0x08, 0x8E);
    idtSetGate(20, @intFromPtr(&isr20), 0x08, 0x8E);
    idtSetGate(21, @intFromPtr(&isr21), 0x08, 0x8E);
    idtSetGate(22, @intFromPtr(&isr22), 0x08, 0x8E);
    idtSetGate(23, @intFromPtr(&isr23), 0x08, 0x8E);
    idtSetGate(24, @intFromPtr(&isr24), 0x08, 0x8E);
    idtSetGate(25, @intFromPtr(&isr25), 0x08, 0x8E);
    idtSetGate(26, @intFromPtr(&isr26), 0x08, 0x8E);
    idtSetGate(27, @intFromPtr(&isr27), 0x08, 0x8E);
    idtSetGate(28, @intFromPtr(&isr28), 0x08, 0x8E);
    idtSetGate(29, @intFromPtr(&isr29), 0x08, 0x8E);
    idtSetGate(30, @intFromPtr(&isr30), 0x08, 0x8E);
    idtSetGate(31, @intFromPtr(&isr31), 0x08, 0x8E);

    idtSetGate(32, @intFromPtr(&isr32), 0x08, 0x8E);
    idtSetGate(33, @intFromPtr(&isr33), 0x08, 0x8E);
    idtSetGate(34, @intFromPtr(&isr34), 0x08, 0x8E);
    idtSetGate(35, @intFromPtr(&isr35), 0x08, 0x8E);
    idtSetGate(36, @intFromPtr(&isr36), 0x08, 0x8E);
    idtSetGate(37, @intFromPtr(&isr37), 0x08, 0x8E);
    idtSetGate(38, @intFromPtr(&isr38), 0x08, 0x8E);
    idtSetGate(39, @intFromPtr(&isr39), 0x08, 0x8E);
    idtSetGate(40, @intFromPtr(&isr40), 0x08, 0x8E);
    idtSetGate(41, @intFromPtr(&isr41), 0x08, 0x8E);
    idtSetGate(42, @intFromPtr(&isr42), 0x08, 0x8E);
    idtSetGate(43, @intFromPtr(&isr43), 0x08, 0x8E);
    idtSetGate(44, @intFromPtr(&isr44), 0x08, 0x8E);
    idtSetGate(45, @intFromPtr(&isr45), 0x08, 0x8E);
    idtSetGate(46, @intFromPtr(&isr46), 0x08, 0x8E);
    idtSetGate(47, @intFromPtr(&isr47), 0x08, 0x8E);

    idtSetGate(128, @intFromPtr(&isr128), 0x08, 0x8E);
    idtSetGate(177, @intFromPtr(&isr177), 0x08, 0x8E);
    idtFlush(@intFromPtr(&idt_pointer));
    out.kputs("FLUSH\n");
}

export fn isrHandler(regs: *IDTRegister) void
{
    const tmp: u32 = regs.int_nb;
    if(regs.int_nb < 32 and regs.int_nb >= 0)
        kpanic(error_messages[tmp]);
}

var irq_routines: [16]?*const fn(*IDTRegister) void = undefined;

export fn irqHandler(regs: *IDTRegister) void
{
    const handler = irq_routines[regs.int_nb - 32];
    if(handler) |i|
        i(regs);
    if(regs.int_nb >= 40)
        ports.out(u8, 0xA0, 0x20);
    ports.out(u8, 0x20, 0x20);
}

pub fn irqInstallHandler(irq: usize, handler: *const fn(*IDTRegister) void) void
{
    out.kputs("set irq\n");
    out.putNb(irq);
    out.kputs("\n");
    out.putNb(@intFromPtr(handler));
    out.kputs("\n");
    irq_routines[irq] = handler;
}

pub fn irqUninstallHandler(irq: i32) void
{
    irq_routines[irq] = undefined;
}

comptime
{
    asm
    (
        \\ .section .text
        \\
        \\ .extern isr_handler
        \\ .extern irq_handler
        \\
        \\ isrCommonStub:
        \\     pusha
        \\     mov %dx, %ax
        \\     push %eax
        \\     mov %cr2, %eax
        \\     push %eax
        \\
        \\     mov $0x10, %ax
        \\     mov %ax, %ds
        \\     mov %ax, %es
        \\     mov %ax, %fs
        \\     mov %ax, %gs
        \\
        \\     push %esp
        \\     call isrHandler
        \\
        \\     add $8, %esp
        \\     pop %ebx
        \\     mov %bx, %ds
        \\     mov %bx, %es
        \\     mov %bx, %fs
        \\     mov %bx, %gs
        \\
        \\     popa
        \\     add $8, %esp
        \\     sti
        \\     iret
        \\
        \\ irqCommonStub:
        \\     pusha
        \\     mov %ds, %eax
        \\     push %eax
        \\     mov %cr2, %eax
        \\     push %eax
        \\
        \\     mov $0x10, %ax
        \\     mov %ax, %ds
        \\     mov %ax, %es
        \\     mov %ax, %fs
        \\     mov %ax, %gs
        \\
        \\     push %esp
        \\     call irqHandler
        \\
        \\     add $8, %esp
        \\     pop %ebx
        \\     mov %bx, %ds
        \\     mov %bx, %es
        \\     mov %bx, %fs
        \\     mov %bx, %gs
        \\
        \\     popa
        \\     add $8, %esp
        \\     sti
        \\     iret
    );
}

comptime
{
    asm
    (
        \\ .section .text
        \\ .macro isrGenerate i
        \\ .align 4
        \\ .type isr\i, @function
        \\ .global isr\i
        \\
        \\ isr\i:
        \\ cli
        \\ .if(\i != 8 && !(\i >= 10 && \i <= 14) || \i >= 32)
        \\     pushl $0
        \\ .endif
        \\
        \\ pushl $\i
        \\ .if(\i >= 32 && \i <= 47)
        \\     jmp irqCommonStub
        \\ .endif
        \\     jmp isrCommonStub
        \\ .endmacro
        \\
        \\ isrGenerate 0
        \\ isrGenerate 1
        \\ isrGenerate 2
        \\ isrGenerate 3
        \\ isrGenerate 4
        \\ isrGenerate 5
        \\ isrGenerate 6
        \\ isrGenerate 7
        \\ isrGenerate 8
        \\ isrGenerate 9
        \\ isrGenerate 10
        \\ isrGenerate 11
        \\ isrGenerate 12
        \\ isrGenerate 13
        \\ isrGenerate 14
        \\ isrGenerate 15
        \\ isrGenerate 16
        \\ isrGenerate 17
        \\ isrGenerate 18
        \\ isrGenerate 19
        \\ isrGenerate 20
        \\ isrGenerate 21
        \\ isrGenerate 22
        \\ isrGenerate 23
        \\ isrGenerate 24
        \\ isrGenerate 25
        \\ isrGenerate 26
        \\ isrGenerate 27
        \\ isrGenerate 28
        \\ isrGenerate 29
        \\ isrGenerate 30
        \\ isrGenerate 31
        \\
        \\ isrGenerate 32
        \\ isrGenerate 33
        \\ isrGenerate 34
        \\ isrGenerate 35
        \\ isrGenerate 36
        \\ isrGenerate 37
        \\ isrGenerate 38
        \\ isrGenerate 39
        \\ isrGenerate 40
        \\ isrGenerate 41
        \\ isrGenerate 42
        \\ isrGenerate 43
        \\ isrGenerate 44
        \\ isrGenerate 45
        \\ isrGenerate 46
        \\ isrGenerate 47
        \\
        \\ isrGenerate 128
        \\ isrGenerate 177
    );
}

pub fn idtSetGate(num: u8, base: u32, segment_selector: u16, flags: u8) void
{
    idt_entries[num].base_low = @truncate(base);
    idt_entries[num].base_high = @truncate(base >> 16);
    idt_entries[num].reserved = 0;
    idt_entries[num].segment_selector = segment_selector;
    idt_entries[num].flags = flags;
}
