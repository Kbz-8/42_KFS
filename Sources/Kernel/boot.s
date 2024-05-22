format ELF
use32

; Magic value that lets bootloader find header
magic_value = 0x1BADB002 

; Flags
flags = 00000011b

; Multiboot header that marks program as a kernel
section '.multiboot'
	align 4
	dd magic_value
	dd flags
	dd -(magic_value + flags)

section '.bss' align 16
	stack_bottom:
	resb 16384 ; 16KB
	stack_top:

section '.text'
	extrn kernel_main
	
	public _start
	_start: ; Entering 32 bits protected mode

		; Setting up the stack
		mov [stack_top], esp

		call kernel_main

		; Put the system into an infinite loop
		cli
		jmp $
