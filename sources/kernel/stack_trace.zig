const libk = @import("libk");

const StackFrame = packed struct
{
    esp: ?*StackFrame,
    eip: u32
};

pub fn stackTrace(max_frame_stack: usize) void
{
    var stk: ?*StackFrame = null;
    asm volatile
    (
        \\ movl %ebp, %eax
        : [stk] "={eax}" (stk)
        :
        : "memory"
    );
    libk.io.kputs("================= Stack Trace ================= \n");
    var frame: usize = 0;
    while(stk.?.esp != null and frame < max_frame_stack) : (frame += 1)
    {
        libk.io.kprintf("fn 0x{} {}()\n", .{ stk.?.eip, "??" });
        stk = stk.?.esp;
    }
    libk.io.kputs("=============== End Stack Trace =============== \n");
}
