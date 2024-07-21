pub const SHT_NULL     = 0;
pub const SHT_PROGBITS = 1;
pub const SHT_SYMTAB   = 2;
pub const SHT_STRTAB   = 3;
pub const SHT_RELA     = 4;
pub const SHT_HASH     = 5;
pub const SHT_DYNAMIC  = 6;
pub const SHT_NOTE     = 7;
pub const SHT_NOBITS   = 8;
pub const SHT_REL      = 9;
pub const SHT_SHLIB    = 10;
pub const SHT_DYNSYM   = 11;
pub const SHT_LOPROC   = 0x70000000;
pub const SHT_HIPROC   = 0x7fffffff;
pub const SHT_LOUSER   = 0x80000000;
pub const SHT_HIUSER   = 0xffffffff;

pub const STT_NOTYPE  = 0;
pub const STT_OBJECT  = 1;
pub const STT_FUNC    = 2;
pub const STT_SECTION = 3;
pub const STT_FILE    = 4;
pub const STT_LOPROC  = 13;
pub const STT_HIPROC  = 15;

pub const SectionHeader = extern struct
{
    sh_name: u32,
    sh_type: u32,
    sh_flags: u32,
    sh_addr: u32,
    sh_offset: u32,
    sh_size: u32,
    sh_link: u32,
    sh_info: u32,
    sh_addralign: u32,
    sh_entsize: u32,
};

pub const Symbol = extern struct
{
    st_name: u32,
    st_value: u32,
    st_size: u32,
    st_info: u8,
    st_other: u8,
    st_shndx: u16,
};

pub inline fn stType(i: u8) u8
{
    return i & 0x0F;
}
