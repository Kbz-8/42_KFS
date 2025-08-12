const elf32 = @import("elf32.zig");

pub const BootInfos = struct {
    cmdline: [*:0]const u8 = undefined,
    total_mem: usize = 0,

    shdr: ?[*]elf32.SectionHeader = null,
    shdr_num: usize = 0,

    symtab: ?*elf32.SectionHeader = null,
    symtab_num: usize = 0,

    strtab: ?*elf32.SectionHeader = null,
};
