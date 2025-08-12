const std = @import("std");
const cfg = @import("../config.zig");
const Bus = @import("bus/bus.zig").Bus;

pub const Device = struct {
    bus: *Bus,
    id: DeviceId,
    mmio_base: ?usize = null,
    irq: ?u8 = null,
};

pub const DeviceId = struct {
    vendor: u16,
    device: u16,
    class: u8 = 0,
    subclass: u8 = 0,
};

pub const DriverVTable = struct {
    name: []const u8,
    probe: *const fn (dev: *Device) bool,
    attach: *const fn (dev: *Device) void,
    detach: *const fn (dev: *Device) void = defaultDetach,
};
fn defaultDetach(_: *Device) void {}

const all_drivers = [_]*const DriverVTable{
    &@import("console/vga_text.zig").DRIVER,
};

pub fn drivers() []const *const DriverVTable {
    return &all_drivers;
}

pub const Manager = struct {
    devices: [cfg.Config.max_drivers]?Device = .{null} ** cfg.Config.max_drivers,
    count: usize = 0,

    pub fn attachAll(self: *Manager, bus: *Bus) void {
        var it = bus.deviceIterator();
        while (it.next()) |dev| {
            for (drivers()) |drv| {
                if (drv.probe(dev)) {
                    drv.attach(dev);
                    self.devices[self.count] = dev.*;
                    self.count += 1;
                    break;
                }
            }
        }
    }
};
