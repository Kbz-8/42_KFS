const boot = @import("../kernel/bootinfo.zig");
const elf32 = @import("../kernel/elf32.zig");

// Flags to be set in the ’flags’ member of the multiboot info structure.

// is there basic lower/upper memory information?
const MULTIBOOT_INFO_MEMORY = 0x00000001;
// is there a boot device set?
const MULTIBOOT_INFO_BOOTDEV = 0x00000002;
// is the command-line defined?
const MULTIBOOT_INFO_CMDLINE = 0x00000004;
// are there modules to do something with?
const MULTIBOOT_INFO_MODS = 0x00000008;

// These next two are mutually exclusive

// is there a symbol table loaded?
const MULTIBOOT_INFO_AOUT_SYMS = 0x00000010;
// is there an ELF section header table?
const MULTIBOOT_INFO_ELF_SHDR = 0x00000020;

// is there a full memory map?
const MULTIBOOT_INFO_MEM_MAP = 0x00000040;

// Is there drive info?
const MULTIBOOT_INFO_DRIVE_INFO = 0x00000080;

// Is there a config table?
const MULTIBOOT_INFO_CONFIG_TABLE = 0x00000100;

// Is there a boot loader name?
const MULTIBOOT_INFO_BOOT_LOADER_NAME = 0x00000200;

// Is there a APM table?
const MULTIBOOT_INFO_APM_TABLE = 0x00000400;

// Is there video information?
const MULTIBOOT_INFO_VBE_INFO = 0x00000800;
const MULTIBOOT_INFO_FRAMEBUFFER_INFO = 0x00001000;

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
    const MULTIBOOT_FRAMEBUFFER_TYPE_INDEXED = 0;
    const MULTIBOOT_FRAMEBUFFER_TYPE_RGB = 1;
    const MULTIBOOT_FRAMEBUFFER_TYPE_EGA_TEXT = 2;

    flags: u32,
    mem_lower: u32,
    mem_upper: u32,
    boot_device: u32,
    cmdline: u32,
    mods_count: u32,
    mods_addr: u32,

    u_sym: extern union {
        aout_sym: AoutSymbolTable,
        elf_sec: ElfSectionHeaderTable,
    },

    mmap_length: u32,
    mmap_addr: u32,
    drives_length: u32,
    drives_addr: u32,
    config_table: u32,
    boot_loader_name: u32,

    apm_table: u32,

    vbe_control_info: u32,
    vbe_mode_info: u32,
    vbe_mode: u16,
    vbe_interface_seg: u16,
    vbe_interface_off: u16,
    vbe_interface_len: u16,

    framebuffer_addr: u64,
    framebuffer_pitch: u32,
    framebuffer_width: u32,
    framebuffer_height: u32,
    framebuffer_bpp: u8,

    framebuffer_type: u8,
    u_fb: extern union {
        palette: extern struct {
            addr: u32,
            num_colors: u16,
        },
        rgb: extern struct {
            red_field_position: u8,
            red_mask_size: u8,
            green_field_position: u8,
            green_mask_size: u8,
            blue_field_position: u8,
            blue_mask_size: u8,
        },
    },
};

pub fn populateBootInfos(boot_data: *boot.BootInfos, info: *const MultibootInfo) void {
    boot_data.cmdline = @ptrFromInt(info.cmdline);
    boot_data.total_mem = info.mem_lower + info.mem_upper;

    if ((info.flags & MULTIBOOT_INFO_ELF_SHDR) != 0) {
        boot_data.shdr = @ptrFromInt(info.u_sym.elf_sec.addr);
        boot_data.shdr_num = info.u_sym.elf_sec.num;

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

    if ((info.flags & MULTIBOOT_INFO_VBE_INFO) != 0) {
        boot_data.vbe = .{
            .control_info = info.vbe_control_info,
            .mode_info = info.vbe_mode_info,
            .mode = info.vbe_mode,
            .interface_seg = info.vbe_interface_seg,
            .interface_off = info.vbe_interface_off,
            .interface_len = info.vbe_interface_len,
        };
    }

    if ((info.flags & MULTIBOOT_INFO_FRAMEBUFFER_INFO) != 0) {
        boot_data.framebuffer = .{
            .addr = info.framebuffer_addr,
            .pitch = info.framebuffer_pitch,
            .width = info.framebuffer_width,
            .height = info.framebuffer_height,
            .bpp = info.framebuffer_bpp,
            .type = @enumFromInt(info.framebuffer_type),
            .u = null,
        };

        switch (boot_data.framebuffer.?.type) {
            .indexed => {
                boot_data.framebuffer.?.u = .{
                    .palette = .{
                        .addr = info.u_fb.palette.addr,
                        .num_colors = info.u_fb.palette.num_colors,
                    },
                };
            },
            .rgb => {
                boot_data.framebuffer.?.u = .{
                    .rgb = .{
                        .red_field_position = info.u_fb.rgb.red_field_position,
                        .red_mask_size = info.u_fb.rgb.red_mask_size,
                        .green_field_position = info.u_fb.rgb.green_field_position,
                        .green_mask_size = info.u_fb.rgb.green_mask_size,
                        .blue_field_position = info.u_fb.rgb.blue_field_position,
                        .blue_mask_size = info.u_fb.rgb.blue_mask_size,
                    },
                };
            },
            .ega_text => {},
        }
    }
}
