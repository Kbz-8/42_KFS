const earlyInit = @import("kernel/init.zig").earlyInit;
const kprint = @import("kstd/kprint.zig");
const boot = @import("kernel/bootinfo.zig");
const vesa = @import("drivers/console/vesa_lfb.zig");

export fn kmain(boot_infos: *const boot.BootInfos) void {
    @branchHint(.cold);
    earlyInit(boot_infos);

    for (25..125) |y| {
        for (25..125) |x| {
            vesa.putPixel(x, y, 0xFFFF00FF);
        }
    }
}
