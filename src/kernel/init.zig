const registry = @import("../drivers/registry.zig");
const pci = @import("../drivers/bus/pci.zig");
const boot = @import("../kernel/bootinfo.zig");
const hal = @import("../hal/hal.zig");
const kprint = @import("../kstd/kprint.zig");

pub fn earlyInit(boot_infos: *const boot.BootInfos) void {
    @branchHint(.cold);
    if (boot_infos.framebuffer) |fb| {
        hal.configureLfb(@intCast(fb.addr), fb.width, fb.height, fb.pitch);
        _ = hal.setVideoMode(.vesa_lfb) catch {};
    }
    var manager: registry.Manager = .{};
    var bus = pci.makeBus();
    manager.attachAll(&bus);
    _ = hal.setVideoMode(.vesa_lfb) catch {};
}
