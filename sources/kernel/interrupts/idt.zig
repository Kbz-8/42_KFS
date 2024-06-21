
const IDT_Entry = struct {
    base_low: u16,
    base_middle: u16,
    base_high: u8,
    segment_selector: u8,
	flags: u8,
    reserved1: u8,
    reserved2: u8,
    reserved3: u8,
    reserved4: u8,
    reserved5: u8,
    reserved6: u8,
    reserved7: u8,
    reserved8: u8,
};

const errorHandler = undefined;

var idt : [256]IDT_Entry = undefined;

pub fn init() void
{
	for (idt[0..]) |*entry|
	{
		entry.* = IDT_Entry
		{
			.base_low = @truncate(u16, errorHandler),
			.base_middle = 0,
			.base_high = 0,
			.segment_selector = 0x67,
			.flags = 0xE,
			.reserved1 = 0,
			.reserved2 = 0,
			.reserved3 = 0,
			.reserved4 = 0,
			.reserved5 = 0,
			.reserved6 = 0,
			.reserved7 = 0,
			.reserved8 = 0,
		};
	}
}