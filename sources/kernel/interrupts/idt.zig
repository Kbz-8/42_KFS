pub const INTERRUPT_GATE = 0x8E;

const IntDesc = packed struct
{
    offset_low: u16,
    selector: u16,
    zero: u8,
    flags: u8,
    offset_high: u16,
};

const IntDescRegister = packed struct
{
    limit: u16,
    base: *[256]IntDesc,
};

// Interrupt Descriptor Table.
var idt: [256]IntDesc = undefined;

const idtr = IntDescRegister
{
    .limit = u16(@sizeOf(@typeOf(idt))),
    .base = &idt,
};

