pub const out = @import("io/out.zig");

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

const IDT_Register = struct
{
	cr2 : u32,
	ds : u32,
	edi: u32,
	esi: u32,
	ebp: u32,
	esp: u32,
	ebx : u32,
	edx: u32, 
	ecx: u32, 
	eax : u32,
	int_nb : u32,
	errcode : u32,
	eip : u32,
	csm : u32,
	eflags : u32,
	useresp : u32,
	ss : u32,
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

	IDT_setGate(0, &isr0, 0x08, 0x8E);
	IDT_setGate(1, &isr1, 0x08, 0x8E);
	IDT_setGate(2, &isr2, 0x08, 0x8E);
	IDT_setGate(3, &isr3, 0x08, 0x8E);
	IDT_setGate(4, &isr4, 0x08, 0x8E);
	IDT_setGate(5, &isr5, 0x08, 0x8E);
	IDT_setGate(6, &isr6, 0x08, 0x8E);
	IDT_setGate(7, &isr7, 0x08, 0x8E);
	IDT_setGate(8, &isr8, 0x08, 0x8E);
	IDT_setGate(9, &isr9, 0x08, 0x8E);
	IDT_setGate(10, &isr10, 0x08, 0x8E);
	IDT_setGate(11, &isr11, 0x08, 0x8E);
	IDT_setGate(12, &isr12, 0x08, 0x8E);
	IDT_setGate(13, &isr13, 0x08, 0x8E);
	IDT_setGate(14, &isr14, 0x08, 0x8E);
	IDT_setGate(15, &isr15, 0x08, 0x8E);
	IDT_setGate(16, &isr16, 0x08, 0x8E);
	IDT_setGate(17, &isr17, 0x08, 0x8E);
	IDT_setGate(18, &isr18, 0x08, 0x8E);
	IDT_setGate(19, &isr19, 0x08, 0x8E);
	IDT_setGate(20, &isr20, 0x08, 0x8E);
	IDT_setGate(21, &isr21, 0x08, 0x8E);
	IDT_setGate(22, &isr22, 0x08, 0x8E);
	IDT_setGate(23, &isr23, 0x08, 0x8E);
	IDT_setGate(24, &isr24, 0x08, 0x8E);
	IDT_setGate(25, &isr25, 0x08, 0x8E);
	IDT_setGate(26, &isr26, 0x08, 0x8E);
	IDT_setGate(27, &isr27, 0x08, 0x8E);
	IDT_setGate(28, &isr28, 0x08, 0x8E);
	IDT_setGate(29, &isr29, 0x08, 0x8E);
	IDT_setGate(30, &isr30, 0x08, 0x8E);
	IDT_setGate(31, &isr31, 0x08, 0x8E);

	IDT_setGate(32, irq0, 0x07, 0x8E);
	IDT_setGate(33, irq1, 0x07, 0x8E);
	IDT_setGate(34, irq2, 0x07, 0x8E);
	IDT_setGate(35, irq3, 0x07, 0x8E);
	IDT_setGate(36, irq4, 0x07, 0x8E);
	IDT_setGate(37, irq5, 0x07, 0x8E);
	IDT_setGate(38, irq6, 0x07, 0x8E);
	IDT_setGate(39, irq7, 0x07, 0x8E);
	IDT_setGate(40, irq8, 0x07, 0x8E);
	IDT_setGate(41, irq9, 0x07, 0x8E);
	IDT_setGate(42, irq10, 0x07, 0x8E);
	IDT_setGate(43, irq11, 0x07, 0x8E);
	IDT_setGate(44, irq12, 0x07, 0x8E);
	IDT_setGate(45, irq13, 0x07, 0x8E);
	IDT_setGate(46, irq14, 0x07, 0x8E);
	IDT_setGate(47, irq15, 0x07, 0x8E);
	
	IDT_setGate(128, isr128, 0x08, 0x8E);
	IDT_setGate(177, isr177, 0x08, 0x8E);

	IDT_flush(&IDTPointer);
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

pub fn isr_handler(regs : *IDT_Register) void
{
	if (regs.int_nb < 32)
	{
		out.kputs(error_messages[regs.int_nb]); // todo: put kernel panic
	}

}


var irq_routines = [_][] const i32 {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

fn irq_install_handler(irq : i32, handler : fn(u32) i32) void
{
	irq_routines[irq] = handler;
}

fn irq_uninstall_handler(irq : i32) void
{
	irq_routines[irq] = 0;
}

pub fn irq_handler(regs : *IDT_Register) void
{
	const handler = irq_routines[regs.int_nb - 32];

	if (handler)
		handler(regs);

	if (regs.int_nb >= 40)
		outPortB(0x0A, 0x20);
	
	outPortB(0x20, 0x20);
}
pub fn IDT_setGate(num : u8, base : u32, segment_selector : u16, flags : u8) void
{
	IDTEntry[num].base_low = base & 0xFFFF;
	IDTEntry[num].base_high = (base >> 16) & 0xFFFF;
	IDTEntry[num].segment_selector = segment_selector;
	IDTEntry[num].flags = flags | 0x60;
}