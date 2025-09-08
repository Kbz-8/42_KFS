const elf32 = @import("elf32.zig");

pub const FramebufferType = enum(u8) {
    indexed = 0,
    rgb = 1,
    ega_text = 2,
};

pub const BootInfos = struct {
    cmdline: [*:0]const u8 = undefined,
    total_mem: usize = 0,

    shdr: ?[*]elf32.SectionHeader = null,
    shdr_num: usize = 0,

    symtab: ?*elf32.SectionHeader = null,
    symtab_num: usize = 0,

    strtab: ?*elf32.SectionHeader = null,

    vbe: ?struct {
        control_info: u32,
        mode_info: u32,
        mode: u16,
        interface_seg: u16,
        interface_off: u16,
        interface_len: u16,
    } = null,

    framebuffer: ?struct {
        addr: u64,
        pitch: u32,
        width: u32,
        height: u32,
        bpp: u8,

        type: FramebufferType,
        u: ?extern union {
            palette: extern struct {
                addr: u32 = 0,
                num_colors: u16 = 0,
            },
            rgb: extern struct {
                red_field_position: u8 = 0,
                red_mask_size: u8 = 0,
                green_field_position: u8 = 0,
                green_mask_size: u8 = 0,
                blue_field_position: u8 = 0,
                blue_mask_size: u8 = 0,
            },
        },
    } = null,
};
