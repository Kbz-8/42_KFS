const registry = @import("../registry.zig");
const buspkg = @import("bus.zig");

const FakeCtx = struct {
    done: bool = false,
    dev: registry.Device,
};

fn next(ctx_ptr: *anyopaque) ?*registry.Device {
    const ctx: *FakeCtx = @alignCast(@ptrCast(ctx_ptr));
    if (ctx.done)
        return null;
    ctx.done = true;
    return &ctx.dev;
}

var global_ctx: FakeCtx = .{
    .dev = .{
        .bus = undefined,
        .id = .{ .vendor = 0, .device = 0 },
        .mmio_base = null,
        .irq = 4,
    },
};

pub fn makeBus() buspkg.Bus {
    return .{ .deviceIterator = struct {
        fn f() buspkg.DeviceIter {
            return .{ .nextFn = next, .ctx = @ptrCast(&global_ctx) };
        }
    }.f };
}
