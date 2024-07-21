ENTRY(_start)

SECTIONS
{
	. = 2M;

	.text : ALIGN(0x1000)
	{
		KEEP(*(.multiboot))
		*(.text)
	}

	.rodata : ALIGN(0x1000)
	{
		*(.rodata)
	}

	.data : ALIGN(0x1000)
	{
		*(.data)
	}

	.bss : ALIGN(0x1000)
	{
		*(COMMON)
		*(.bss)
	}

	.strtab : ALIGN(0x1000)
	{
		*(.strtab)
	}

	.shstrtab : ALIGN(0x1000)
	{
		*(.shstrtab)
	}
}
