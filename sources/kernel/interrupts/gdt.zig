
const GDT_Entry = packed struct {
	limit : u16,
	base_low : u16,
	base_middle : u8,
	access : u8,
	flags : u8,
	base_high : u8
};

const TSS_Entry = packed struct {
	prev_tss: u32,
	esp0: u32,
	ss0: u32,
	esp1: u32,
	ss1: u32,
	esp2: u32,
	ss2: u32,
	cr3: u32,
	eip: u32,
	eflags: u32,
	eax: u32,
	ecx: u32,
	edx: u32,
	ebx: u32,
	esp: u32,
	ebp: u32,
	esi: u32,
	edi: u32,
	es: u32,
	cs: u32,
	ss: u32,
	ds: u32,
	fs: u32,
	gs: u32,
	ldt: u32,
	trap: u32,
	iomap_base: u32
};

const GDT_Pointer = packed struct {
	limit : u16,
	base : *GDT_Entry
};

var GDTEntry : [6]GDT_Entry = undefined;

var TSSEntry: TSS_Entry = .{
        .prev_tss = 0,
        .esp0 = 0,    
        .ss0 = 0,     
        .esp1 = 0,    
        .ss1 = 0,     
        .esp2 = 0,    
        .ss2 = 0,     
        .cr3 = 0,     
        .eip = 0,     
        .eflags = 0,  
        .eax = 0,     
        .ecx = 0,     
        .edx = 0,     
        .ebx = 0,     
        .esp = 0,     
        .ebp = 0,     
        .esi = 0,     
        .edi = 0,     
        .es = 0,      
        .cs = 0,      
        .ss = 0,      
        .ds = 0,      
        .fs = 0,      
        .gs = 0,      
        .ldt = 0,     
        .trap = 0,    
        .iomap_base = 0,
    };

var GDTPointer : GDT_Pointer = undefined;

comptime {
	asm (
		\\.type GDT_Flush, @function
		\\ GDT_Flush:
		\\ mov +4(%esp), %eax
		\\ lgdt (%eax)
		\\ mov $0x10, %ax
		\\ mov %ax, %ds
		\\ mov %ax, %es
		\\ mov %ax, %fs
		\\ mov %ax, %gs
		\\ mov %ax, %ss
		\\ ljmp $0x08, $1f
		\\ 1: ret
	);
}

comptime {
	asm (
		\\.type TSS_Flush, @function
		\\TSS_Flush:
		\\mov $0x2B, %ax
		\\ltr %ax
		\\ret
	);
}

extern fn GDT_Flush(*const GDT_Pointer) void;

extern fn TSS_Flush() void;

fn writeTSS(num : u32, ss0 : u16, esp0 : u32) void
{
	const base : u32 = @intFromPtr(&TSSEntry);
	const limit : u32 = base + @sizeOf(TSS_Entry);

	GDT_setGate(num, base, limit, 0xE9, 0x00);
	TSSEntry.ss0 = ss0;
	TSSEntry.esp0 = esp0;

	TSSEntry.cs = 0x08 | 0x3;
	TSSEntry.ss = 0x10 | 0x3;
	TSSEntry.ds = 0x10 | 0x3;
	TSSEntry.es = 0x10 | 0x3;
	TSSEntry.fs = 0x10 | 0x3;
	TSSEntry.gs = 0x10 | 0x3;

}
pub fn GDT_Init() void
{
	GDTPointer.limit = @sizeOf(GDT_Entry) * 6 - 1;
	GDTPointer.base = &GDTEntry[0];

	GDT_setGate(0,0,0,0,0);
	GDT_setGate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);
	GDT_setGate(2, 0, 0xFFFFFFFF, 0x92, 0xCF);
	GDT_setGate(3, 0, 0xFFFFFFFF, 0xFA, 0xCF);
	GDT_setGate(4, 0, 0xFFFFFFFF, 0xF2, 0xCF);
	writeTSS(5, 0x10, 0x0);
	GDT_Flush(&GDTPointer);
	TSS_Flush();
}

pub fn GDT_setGate(num : u32, base : u32, limit : u32, access : u8, flags : u8) void
{
	GDTEntry[num].base_low = @truncate(base);
	GDTEntry[num].base_middle = @truncate(base >> 16);
	GDTEntry[num].base_high = @truncate(base >> 24);
	GDTEntry[num].limit = @truncate(limit);
	GDTEntry[num].flags = @truncate(limit >> 16);
	GDTEntry[num].flags |= (flags & 0xF0);
	GDTEntry[num].access = access;
}