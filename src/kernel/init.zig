const registry = @import("../drivers/registry.zig");
const pci = @import("../drivers/bus/pci.zig");

pub fn earlyInit() void {
    @branchHint(.cold);
    var manager: registry.Manager = .{};
    var bus = pci.makeBus();
    manager.attachAll(&bus);
}
