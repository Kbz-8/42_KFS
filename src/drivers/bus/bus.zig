const registry = @import("../registry.zig");

pub const Bus = struct {
    deviceIterator: *const fn () DeviceIter,
};

pub const DeviceIter = struct {
    nextFn: *const fn (ctx: *anyopaque) ?*registry.Device,
    ctx: *anyopaque,
    pub fn next(self: *DeviceIter) ?*registry.Device {
        return self.nextFn(self.ctx);
    }
};
