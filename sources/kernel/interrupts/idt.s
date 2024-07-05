
.macro isr_generate i
	.align 4
	.type isr\i, @function
	.global isr\i

	isr\i:
	.if (\i != 8 && !(\i >= 10 && \i <= 14) && \i != 17)
		push $0
	.endif
	push $\i
	jmp isr_common_stub
.endmacro

isr_common_stub:
	pusha
	mov %eax, %ds
	push %eax
	mov %eax, %cr2
	push %eax

	mov %ax, 0x10
	mov %ds, %ax
	mov %es, %ax
	mov %fs, %ax
	mov %gs, %ax

	push esp
	call isr_handler

	add %esp, 8
	pop %ebx
	mov %ds, %bx
	mov %es, %bx
	mov %fs, %bx
	mov %gs, %bx

	popa
	add %esp, 8
	sti
	iret

.type isr_common_stub, @function

isrGenerate 0
isrGenerate 1
isrGenerate 2
isrGenerate 3
isrGenerate 4
isrGenerate 5
isrGenerate 6
isrGenerate 7
isrGenerate 8
isrGenerate 9
isrGenerate 10
isrGenerate 11
isrGenerate 12
isrGenerate 13
isrGenerate 14
isrGenerate 15
isrGenerate 16
isrGenerate 17
isrGenerate 18
isrGenerate 19
isrGenerate 20
isrGenerate 21
isrGenerate 22
isrGenerate 23
isrGenerate 24
isrGenerate 25
isrGenerate 26
isrGenerate 27
isrGenerate 28
isrGenerate 29
isrGenerate 30
isrGenerate 31

isrGenerate 32
isrGenerate 33
isrGenerate 34
isrGenerate 35
isrGenerate 36
isrGenerate 37
isrGenerate 38
isrGenerate 39
isrGenerate 40
isrGenerate 41
isrGenerate 42
isrGenerate 43
isrGenerate 44
isrGenerate 45
isrGenerate 46
isrGenerate 47

isrGenerate 128
isrGenerate 177