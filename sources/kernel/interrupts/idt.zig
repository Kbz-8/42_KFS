
const IDT_Entry = packed struct
{
	base_low : u16,
	segment_selector : u16,
	reserved : u8,
	flags : u8,
	base_high : u16,
};

const IDT_Pointer = packed struct
{
	limit : u16,
	base : u32,
};

var IDTEntry = IDT_Entry[256] 
{
	.base_low = 0,
	.segment_selector = 0,
	.reserved = 0,
	.flags = 0,
	.base_high = 0
};

var IDTPointer = IDT_Pointer
{
	.limit = 0,
	.base = 0,
};

pub fn IDT_flush(t : u32) u32
{
	asm volatile 
	(
		\\ movl %[t], %%eax
        \\ lidt (%%eax)
		\\ sti
        : [ret] "={eax}" (-> u32)
        : [t] "%[t]" (t)
        : "memory"
	);
}

pub fn IDT_init() void
{
	IDTPointer.limit = @sizeOf(IDT_Entry) * 256 - 1;
	IDTPointer.base = @as(u32, &IDTEntry);
	@memset(IDT_Entry, 0);

	// init "master" chip (commands : 0x20 data : 0x21) and "slave" chip (commands : 0xA0 data : 0xA1)
	outPortB(0x20, 0x11);
	outPortB(0xA0, 0x11);

	outPortB(0x21, 0x20);
	outPortB(0xA1, 0x28);

	outPortB(0x21, 0x04);
	outPortB(0xA1, 0x02);

	outPortB(0x21, 0x01);
	outPortB(0xA1, 0x01);
	
	outPortB(0x21, 0x0);
	outPortB(0xA1, 0x0);

	IDT_setGate(0, @as(u32, &isr0), 0x08, 0x8E);
	IDT_setGate(1, @as(u32, &isr1), 0x08, 0x8E);
	IDT_setGate(2, @as(u32, &isr2), 0x08, 0x8E);
	IDT_setGate(3, @as(u32, &isr3), 0x08, 0x8E);
	IDT_setGate(4, @as(u32, &isr4), 0x08, 0x8E);
	IDT_setGate(5, @as(u32, &isr5), 0x08, 0x8E);
	IDT_setGate(6, @as(u32, &isr6), 0x08, 0x8E);
	IDT_setGate(7, @as(u32, &isr7), 0x08, 0x8E);
	IDT_setGate(8, @as(u32, &isr8), 0x08, 0x8E);
	IDT_setGate(9, @as(u32, &isr9), 0x08, 0x8E);
	IDT_setGate(10, @as(u32, &isr10), 0x08, 0x8E);
	IDT_setGate(11, @as(u32, &isr11), 0x08, 0x8E);
	IDT_setGate(12, @as(u32, &isr12), 0x08, 0x8E);
	IDT_setGate(13, @as(u32, &isr13), 0x08, 0x8E);
	IDT_setGate(14, @as(u32, &isr14), 0x08, 0x8E);
	IDT_setGate(15, @as(u32, &isr15), 0x08, 0x8E);
	IDT_setGate(16, @as(u32, &isr16), 0x08, 0x8E);
	IDT_setGate(17, @as(u32, &isr17), 0x08, 0x8E);
	IDT_setGate(18, @as(u32, &isr18), 0x08, 0x8E);
	IDT_setGate(19, @as(u32, &isr19), 0x08, 0x8E);
	IDT_setGate(20, @as(u32, &isr20), 0x08, 0x8E);
	IDT_setGate(21, @as(u32, &isr21), 0x08, 0x8E);
	IDT_setGate(22, @as(u32, &isr22), 0x08, 0x8E);
	IDT_setGate(23, @as(u32, &isr23), 0x08, 0x8E);
	IDT_setGate(24, @as(u32, &isr24), 0x08, 0x8E);
	IDT_setGate(25, @as(u32, &isr25), 0x08, 0x8E);
	IDT_setGate(26, @as(u32, &isr26), 0x08, 0x8E);
	IDT_setGate(27, @as(u32, &isr27), 0x08, 0x8E);
	IDT_setGate(28, @as(u32, &isr28), 0x08, 0x8E);
	IDT_setGate(29, @as(u32, &isr29), 0x08, 0x8E);
	IDT_setGate(30, @as(u32, &isr30), 0x08, 0x8E);
	IDT_setGate(31, @as(u32, &isr31), 0x08, 0x8E);

	IDT_setGate(128, @as(u32, &isr128), 0x08, 0x8E);
	IDT_setGate(177, @as(u32, &isr177), 0x08, 0x8E);

	IDT_flush(@as(u32, IDTPointer));
}

pub fn outPortB(port : u16, value : u8) void
{
	asm volatile ( 
		\\ movl %[port], %%eax
        \\ movb %[value], %%al
        \\ outb %%al, %%dx
        : [ret] "={eax}" (-> u8)
        : [port] "%[port]" (port),
          [value] "%[value]" (value)
        : "memory" );
}

pub fn IDT_setGate(num : u8, base : u32, segment_selector : u16, flags : u8) void
{
	IDTEntry[num].base_low = base & 0xFFFF;
	IDTEntry[num].base_high = (base >> 16) & 0xFFFF;
	IDTEntry[num].segment_selector = segment_selector;
	IDTEntry[num].flags = flags | 0x60;
}