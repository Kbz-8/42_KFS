const boot = @import("../../boot.zig");
const elf32 = @import("../../sys/elf32.zig");

const MULTIBOOT_INFO_ELF_SHDR = 0x00000020;
const MULTIBOOT_INFO_AOUT_SYMS = 0x00000010;

const AoutSymbolTable = extern struct {
    tabsize: u32,
    strsize: u32,
    addr: u32,
    reserved: u32,
};

const ElfSectionHeaderTable = extern struct {
    num: u32,
    size: u32,
    addr: u32,
    shndx: u32,
};

const MultibootInfo = extern struct {
    flags: u32,
    mem_lower: u32,
    mem_upper: u32,
    boot_device: u32,
    cmdline: u32,
    mods_count: u32,
    mods_addr: u32,

    u: extern union {
        aout_sym: AoutSymbolTable,
        elf_sec: ElfSectionHeaderTable,
    },

    mmap_length: u32,
    mmap_addr: u32,
    drives_length: u32,
    drives_addr: u32,
    config_table: u32,
    boot_loader_name: u32,
};

pub fn populateBootData(boot_data: *boot.Boot, info: *MultibootInfo) void {
    boot_data.cmdline = @ptrFromInt(info.cmdline);
    boot_data.total_mem = info.mem_lower + info.mem_upper;
    if ((info.flags & MULTIBOOT_INFO_ELF_SHDR) != 0) {
        boot_data.shdr = @ptrFromInt(info.u.elf_sec.addr);
        boot_data.shdr_num = info.u.elf_sec.num;

        for (0..boot_data.shdr_num) |i| {
            const shdr: *elf32.SectionHeader = &boot_data.shdr.?[i];
            if (shdr.sh_type == elf32.SHT_SYMTAB) {
                boot_data.symtab = @ptrCast(shdr);
                boot_data.symtab_num = shdr.sh_size / @sizeOf(elf32.Symbol);
            }
            if (shdr.sh_type == elf32.SHT_STRTAB and boot_data.strtab == null)
                boot_data.strtab = shdr;
        }
    }
}
