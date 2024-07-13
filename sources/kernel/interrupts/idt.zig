pub const ports = @import("../ports/ports.zig");
pub const out = @import("../io/out.zig");
pub const kpanic = @import("../panic.zig").kpanic;
pub const kernel = @import("../kmain.zig");
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
	base : *[256]IDT_Entry,
};

pub const IDT_Register = packed struct
{
	cr2 : u32,
	ds : u32,
	edi: u32,
	esi: u32,
	ebp: u32,
	esp: u32,
	ebx: u32,
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

var IDTEntry : [256]IDT_Entry = undefined;

var IDTPointer = IDT_Pointer
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


pub fn IDT_flush(t : u32) void
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

pub fn IDT_Init() void
{
	out.kputs("INIT\n");
	for (0..255) |i|
	{
		IDTEntry[i].base_low = 0;
		IDTEntry[i].segment_selector = 0;
		IDTEntry[i].reserved = 0;
		IDTEntry[i].flags = 0;
		IDTEntry[i].base_high = 0;
	}
	IDTPointer.limit = @sizeOf(IDT_Entry) * 256 - 1;
	IDTPointer.base = &IDTEntry;

	// init "master" chip (commands : 0x20 data : 0x21) and "slave" chip (commands : 0xA0 data : 0xA1)
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
	IDT_setGate(0, @intFromPtr(&isr0), 0x08, 0x8E);
	IDT_setGate(1, @intFromPtr(&isr1), 0x08, 0x8E);
	IDT_setGate(2, @intFromPtr(&isr2), 0x08, 0x8E);
	IDT_setGate(3, @intFromPtr(&isr3), 0x08, 0x8E);
	IDT_setGate(4, @intFromPtr(&isr4), 0x08, 0x8E);
	IDT_setGate(5, @intFromPtr(&isr5), 0x08, 0x8E);
	IDT_setGate(6, @intFromPtr(&isr6), 0x08, 0x8E);
	IDT_setGate(7, @intFromPtr(&isr7), 0x08, 0x8E);
	IDT_setGate(8, @intFromPtr(&isr8), 0x08, 0x8E);
	IDT_setGate(9, @intFromPtr(&isr9), 0x08, 0x8E);
	IDT_setGate(10, @intFromPtr(&isr10), 0x08, 0x8E);
	IDT_setGate(11, @intFromPtr(&isr11), 0x08, 0x8E);
	IDT_setGate(12, @intFromPtr(&isr12), 0x08, 0x8E);
	IDT_setGate(13, @intFromPtr(&isr13), 0x08, 0x8E);
	IDT_setGate(14, @intFromPtr(&isr14), 0x08, 0x8E);
	IDT_setGate(15, @intFromPtr(&isr15), 0x08, 0x8E);
	IDT_setGate(16, @intFromPtr(&isr16), 0x08, 0x8E);
	IDT_setGate(17, @intFromPtr(&isr17), 0x08, 0x8E);
	IDT_setGate(18, @intFromPtr(&isr18), 0x08, 0x8E);
	IDT_setGate(19, @intFromPtr(&isr19), 0x08, 0x8E);
	IDT_setGate(20, @intFromPtr(&isr20), 0x08, 0x8E);
	IDT_setGate(21, @intFromPtr(&isr21), 0x08, 0x8E);
	IDT_setGate(22, @intFromPtr(&isr22), 0x08, 0x8E);
	IDT_setGate(23, @intFromPtr(&isr23), 0x08, 0x8E);
	IDT_setGate(24, @intFromPtr(&isr24), 0x08, 0x8E);
	IDT_setGate(25, @intFromPtr(&isr25), 0x08, 0x8E);
	IDT_setGate(26, @intFromPtr(&isr26), 0x08, 0x8E);
	IDT_setGate(27, @intFromPtr(&isr27), 0x08, 0x8E);
	IDT_setGate(28, @intFromPtr(&isr28), 0x08, 0x8E);
	IDT_setGate(29, @intFromPtr(&isr29), 0x08, 0x8E);
	IDT_setGate(30, @intFromPtr(&isr30), 0x08, 0x8E);
	IDT_setGate(31, @intFromPtr(&isr31), 0x08, 0x8E);

	IDT_setGate(32, @intFromPtr(&isr32), 0x08, 0x8E);
	IDT_setGate(33, @intFromPtr(&isr33), 0x08, 0x8E);
	IDT_setGate(34, @intFromPtr(&isr34), 0x08, 0x8E);
	IDT_setGate(35, @intFromPtr(&isr35), 0x08, 0x8E);
	IDT_setGate(36, @intFromPtr(&isr36), 0x08, 0x8E);
	IDT_setGate(37, @intFromPtr(&isr37), 0x08, 0x8E);
	IDT_setGate(38, @intFromPtr(&isr38), 0x08, 0x8E);
	IDT_setGate(39, @intFromPtr(&isr39), 0x08, 0x8E);
	IDT_setGate(40, @intFromPtr(&isr40), 0x08, 0x8E);
	IDT_setGate(41, @intFromPtr(&isr41), 0x08, 0x8E);
	IDT_setGate(42, @intFromPtr(&isr42), 0x08, 0x8E);
	IDT_setGate(43, @intFromPtr(&isr43), 0x08, 0x8E);
	IDT_setGate(44, @intFromPtr(&isr44), 0x08, 0x8E);
	IDT_setGate(45, @intFromPtr(&isr45), 0x08, 0x8E);
	IDT_setGate(46, @intFromPtr(&isr46), 0x08, 0x8E);
	IDT_setGate(47, @intFromPtr(&isr47), 0x08, 0x8E);

	IDT_setGate(128, @intFromPtr(&isr128), 0x08, 0x8E);
	IDT_setGate(177, @intFromPtr(&isr177), 0x08, 0x8E);
	IDT_flush(@intFromPtr(&IDTPointer));
	out.kputs("FLUSH\n");
}

export fn isr_handler(regs : *IDT_Register) void
{
	const tmp : u32 = regs.int_nb;
	if (regs.int_nb < 32 and regs.int_nb >= 0)
	{
		kpanic(error_messages[tmp]);
	}
}

var irq_routines : [16]?*const fn(*IDT_Register) void = undefined;

export fn irq_handler(regs : *IDT_Register) void
{
	const handler = irq_routines[regs.int_nb - 32];
	if (handler) |i|
	{
		i(regs);
	}
	if (regs.int_nb >= 40)
	{
		ports.out(u8, 0xA0, 0x20);
	}
	ports.out(u8, 0x20, 0x20);
}

pub fn irq_install_handler(irq : usize, handler : *const fn(*IDT_Register) void) void
{
	kernel.console.kputs("set irq\n");
	kernel.console.putNb(irq);
	kernel.console.kputs("\n");
	kernel.console.putNb(@intFromPtr(handler));
	kernel.console.kputs("\n");
	irq_routines[irq] = handler;
}

pub fn irq_uninstall_handler(irq : i32) void
{
	irq_routines[irq] = undefined;
}

comptime {
	asm (
		\\.extern isr_handler
		\\.extern irq_handler
		\\
		\\isr_common_stub:
		\\pusha
		\\mov %dx, %ax
		\\push %eax
		\\mov %cr2, %eax
		\\push %eax

		\\mov $0x10, %ax
		\\mov %ax, %ds
		\\mov %ax, %es
		\\mov %ax, %fs
		\\mov %ax, %gs

		\\push %esp
		\\call isr_handler

		\\add $8, %esp
		\\pop %ebx
		\\mov %bx, %ds
		\\mov %bx, %es
		\\mov %bx, %fs
		\\mov %bx, %gs

		\\popa
		\\add $8, %esp
		\\sti
		\\iret
		\\
		\\irq_common_stub:
		\\pusha
		\\mov %ds, %eax
		\\push %eax
		\\mov %cr2, %eax
		\\push %eax

		\\mov $0x10, %ax
		\\mov %ax, %ds
		\\mov %ax, %es
		\\mov %ax, %fs
		\\mov %ax, %gs

		\\push %esp
		\\call irq_handler

		\\add $8, %esp
		\\pop %ebx
		\\mov %bx, %ds
		\\mov %bx, %es
		\\mov %bx, %fs
		\\mov %bx, %gs

		\\popa
		\\add $8, %esp
		\\sti
		\\iret
		\\
	);
}

comptime {
	asm (
	\\.macro isr_generate i
	\\.align 4
	\\.type isr\i, @function
	\\.global isr\i

	\\isr\i:
	\\cli
	\\.if (\i != 8 && !(\i >= 10 && \i <= 14) || \i >= 32)
	\\	pushl $0
	\\.endif
	\\
	\\pushl $\i
	\\.if (\i >= 32 && \i <= 47)
	\\	jmp irq_common_stub
	\\.endif
	\\jmp isr_common_stub
	\\.endmacro

	\\ isr_generate 0
	\\ isr_generate 1
	\\ isr_generate 2
	\\ isr_generate 3
	\\ isr_generate 4
	\\ isr_generate 5
	\\ isr_generate 6
	\\ isr_generate 7
	\\ isr_generate 8
	\\ isr_generate 9
	\\ isr_generate 10
	\\ isr_generate 11
	\\ isr_generate 12
	\\ isr_generate 13
	\\ isr_generate 14
	\\ isr_generate 15
	\\ isr_generate 16
	\\ isr_generate 17
	\\ isr_generate 18
	\\ isr_generate 19
	\\ isr_generate 20
	\\ isr_generate 21
	\\ isr_generate 22
	\\ isr_generate 23
	\\ isr_generate 24
	\\ isr_generate 25
	\\ isr_generate 26
	\\ isr_generate 27
	\\ isr_generate 28
	\\ isr_generate 29
	\\ isr_generate 30
	\\ isr_generate 31

	\\ isr_generate 32
	\\ isr_generate 33
	\\ isr_generate 34
	\\ isr_generate 35
	\\ isr_generate 36
	\\ isr_generate 37
	\\ isr_generate 38
	\\ isr_generate 39
	\\ isr_generate 40
	\\ isr_generate 41
	\\ isr_generate 42
	\\ isr_generate 43
	\\ isr_generate 44
	\\ isr_generate 45
	\\ isr_generate 46
	\\ isr_generate 47

	\\ isr_generate 128
	\\ isr_generate 177
	);
}

pub fn IDT_setGate(num : u8, base : u32, segment_selector : u16, flags : u8) void
{
	IDTEntry[num].base_low = @truncate(base);
	IDTEntry[num].base_high = @truncate(base >> 16);
	IDTEntry[num].reserved = 0;
	IDTEntry[num].segment_selector = segment_selector;
	IDTEntry[num].flags = flags;
}