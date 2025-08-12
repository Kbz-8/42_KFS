const earlyInit = @import("kernel/init.zig").earlyInit;
const boot = @import("kernel/bootinfo.zig");

export fn kmain(_: *const boot.BootInfos) void {
    @branchHint(.cold);
    earlyInit();
}
