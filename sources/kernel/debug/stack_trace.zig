const libk = @import("libk");
const boot = @import("../boot.zig");
const elf32 = @import("../sys/elf32.zig");

const builtin = @import("builtin");

const StackFrame = packed struct { esp: ?*StackFrame, eip: u32 };

pub fn stackTrace(max_frame_stack: usize) void {
    var stk = asm (
        \\ movl %ebp, %eax
        : [res] "=r" (-> ?*StackFrame),
    );
    libk.io.kputs("================= Stack Trace ================= \n");

    const is_elf = (boot.kboot_data.symtab_num != 0);
    const is_stripped = builtin.strip_debug_info;

    const strs: [*:0]const u8 = if (boot.kboot_data.strtab != null) @ptrFromInt(boot.kboot_data.strtab.?.sh_addr) else undefined;

    if (is_stripped)
        libk.io.kputs("Warning: debug symbols stripped out\n")
    else if (!is_elf)
        libk.io.kputs("Warning: could not retrieve debug symbols (not ELF format)\n");

    var frame: usize = 0;
    while (stk != null and stk.?.esp != null and frame < max_frame_stack) : (frame += 1) {
        var symbol_found: bool = false;
        var symbol: *elf32.Symbol = undefined;
        if (!is_stripped and is_elf and boot.kboot_data.strtab != null and boot.kboot_data.symtab != null) {
            symbol = @ptrFromInt(boot.kboot_data.symtab.?.sh_addr);
            for (0..boot.kboot_data.symtab_num) |_| {
                if (elf32.stType(symbol.st_info) == elf32.STT_FUNC) {
                    if (stk.?.eip > symbol.st_value and stk.?.eip < symbol.st_value + symbol.st_size) {
                        symbol_found = true;
                        break;
                    }
                }
                symbol = @ptrFromInt(@intFromPtr(symbol) + @sizeOf(elf32.Symbol));
            }
        }
        if (symbol_found)
            libk.io.kprintf("fn 0x{} {}() + {x}\n", .{ stk.?.eip, strs + symbol.st_name, stk.?.eip - symbol.st_value })
        else
            libk.io.kprintf("fn 0x{} ??()\n", .{stk.?.eip});
        stk = stk.?.esp;
    }
    libk.io.kputs("=============== End Stack Trace =============== \n");
}
