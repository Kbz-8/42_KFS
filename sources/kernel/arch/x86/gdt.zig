pub const console = @import("../../io/out.zig");
const boot = @import("boot.zig");

const GDTEntry = packed struct
{
    limit: u16,
    base_low: u16,
    base_middle: u8,
    access: u8,
    flags: u8,
    base_high: u8
};

const TSSEntry = packed struct
{
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

const GDTPointer = packed struct
{
    limit: u16,
    base: *GDTEntry
};

var gdt_entries: *[8]GDTEntry = @ptrFromInt(0x800);

var tss_entry: TSSEntry = .{
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

var gdt_pointer: GDTPointer = undefined;

comptime
{
    asm
    (
        \\ .type gdtFlush, @function
        \\ gdtFlush:
        \\     mov +4(%esp), %eax
        \\     lgdt (%eax)
        \\     mov $0x10, %ax
        \\     mov %ax, %ds
        \\     mov %ax, %es
        \\     mov %ax, %fs
        \\     mov %ax, %gs
        \\     mov %ax, %ss
        \\     ljmp $0x08, $1f
        \\ 1: ret
    );
}

comptime
{
    asm
    (
        \\ .type tssFlush, @function
        \\ tssFlush:
        \\     mov $0x38, %ax
        \\     ltr %ax
        \\     ret
    );
}

extern fn gdtFlush(*const GDTPointer) void;

extern fn tssFlush() void;

fn writeTSS(num: u32, ss0: u16, esp0: u32) void
{
    const base: u32 = @intFromPtr(&tss_entry);
    const limit: u32 = base + @sizeOf(TSSEntry);

    gdtSetGate(num, base, limit, 0xE9, 0x00);

    tss_entry.ss0 = ss0;
    tss_entry.esp0 = esp0;
    tss_entry.cs = 0x08 | 0x3;
    tss_entry.ss = 0x10 | 0x3;
    tss_entry.ds = 0x10 | 0x3;
    tss_entry.es = 0x10 | 0x3;
    tss_entry.fs = 0x10 | 0x3;
    tss_entry.gs = 0x10 | 0x3;
}

pub fn gdtInit() void
{
    gdt_pointer.limit = @sizeOf(GDTEntry) * 8 - 1;
    gdt_pointer.base = &gdt_entries[0];

    gdtSetGate(0, 0, 0, 0, 0);
    gdtSetGate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);
    gdtSetGate(2, 0, 0xFFFFFFFF, 0x92, 0xCF);
	gdtSetGate(3, @intFromPtr(&boot.kernel_stack), @sizeOf(@TypeOf(boot.kernel_stack)) - 1, 0x92, 0xCF);
    gdtSetGate(4, 0, 0xFFFFFFFF, 0xFA, 0xCF);
    gdtSetGate(5, 0, 0xFFFFFFFF, 0xF2, 0xCF);
	gdtSetGate(6, @intFromPtr(&boot.user_stack), @sizeOf(@TypeOf(boot.user_stack)) - 1, 0xF2, 0xCF);
    writeTSS(7, 0x10, @intFromPtr(&boot.kernel_stack));
    gdtFlush(&gdt_pointer);
    tssFlush();
}

pub fn gdtSetGate(num: u32, base: u32, limit: u32, access: u8, flags: u8) void
{
    gdt_entries[num].base_low = @truncate(base);
    gdt_entries[num].base_middle = @truncate(base >> 16);
    gdt_entries[num].base_high = @truncate(base >> 24);
    gdt_entries[num].limit = @truncate(limit);
    gdt_entries[num].flags = @truncate(limit >> 16);
    gdt_entries[num].flags |= (flags & 0xF0);
    gdt_entries[num].access = access;
}
