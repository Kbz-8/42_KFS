const ports = @import("../ports/ports.zig");
const logs = @import("../log.zig");

// PIC ports.
const PIC1_CMD = 0x20;
const PIC1_DATA = 0x21;
const PIC2_CMD = 0xA0;
const PIC2_DATA = 0xA1;
// PIC commands:
const ISR_READ = 0x0B;  // Read the In-Service Register.
const EOI = 0x20;  // End of Interrupt.
// Initialization Control Words commands.
const ICW1_INIT = 0x10;
const ICW1_ICW4 = 0x01;
const ICW4_8086 = 0x01;
// Interrupt Vector offsets of exceptions.
const EXCEPTION_0 = 0;
const EXCEPTION_31 = EXCEPTION_0 + 31;
// Interrupt Vector offsets of IRQs.
const IRQ_0 = EXCEPTION_31 + 1;
const IRQ_15 = IRQ_0 + 15;

////
// Remap the PICs so that IRQs don't override software interrupts.
//
fn remapPIC() void
{
    // ICW1: start initialization sequence.
    ports.out(PIC1_CMD, ICW1_INIT | ICW1_ICW4);
    ports.out(PIC2_CMD, ICW1_INIT | ICW1_ICW4);

    // ICW2: Interrupt Vector offsets of IRQs.
    ports.out(PIC1_DATA, IRQ_0);      // IRQ 0..7  -> Interrupt 32..39
    ports.out(PIC2_DATA, IRQ_0 + 8);  // IRQ 8..15 -> Interrupt 40..47

    // ICW3: IRQ line 2 to connect master to slave PIC.
    ports.out(PIC1_DATA, 1 << 2);
    ports.out(PIC2_DATA, 2);

    // ICW4: 80x86 mode.
    ports.out(PIC1_DATA, ICW4_8086);
    ports.out(PIC2_DATA, ICW4_8086);

    // Mask all IRQs.
    ports.out(PIC1_DATA, 0xFF);
    ports.out(PIC2_DATA, 0xFF);
}

pub fn init() void
{
    logs.klog("[Interrupts] loading...");
    remapPIC();
    logs.klog("[Interrupts] loaded");
}
