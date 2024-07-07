
const GDT_Entry = packed struct {
	limit : u16,
	base_low : u16,
	base_middle : u8,
	access : u8,
	flags : u8,
	base_high : u8
};

const GDT_Pointer = packed struct {
	limit : u16,
	base : *GDT_Entry
};

var GDTEntry : [5]GDT_Entry = undefined;

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

extern fn GDT_Flush(*const GDT_Pointer) void;

pub fn GDT_Init() void
{

	GDTPointer.limit = @sizeOf(GDT_Entry) * 5 - 1;
	GDTPointer.base = &GDTEntry[0];

	GDT_setGate(0,0,0,0,0);
	GDT_setGate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);
	GDT_setGate(2, 0, 0xFFFFFFFF, 0x92, 0xCF);
	GDT_setGate(3, 0, 0xFFFFFFFF, 0xFA, 0xCF);
	GDT_setGate(4, 0, 0xFFFFFFFF, 0xF2, 0xCF);

	GDT_Flush(&GDTPointer);
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