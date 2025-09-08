const reg = @import("../registry.zig");
const kprint = @import("../../kstd/kprint.zig");
const hal = @import("../../hal/hal.zig");

fn probe(_: *reg.Device) bool {
    // Only claim the device if an LFB is known
    return hal.lfbInfo() != null;
}

fn attach(_: *reg.Device) void {
    // Switch to VESA LFB and clear to black
    _ = hal.setVideoMode(.vesa_lfb) catch {
        return;
    };
    if (hal.lfbInfo()) |fb| {
        const total: usize = @as(usize, fb.pitch) * @as(usize, fb.height);
        var i: usize = 0;
        while (i < total) : (i += 1) fb.base[i] = 0; // zeroed bytes → black in XRGB8888
    }
    kprint.println("[vesa] linear framebuffer ready", .{});
}

/// Put a single pixel in the current VESA LFB.
/// color is 0xAARRGGBB (XRGB8888 effectively; alpha ignored by hardware).
pub fn putPixel(x: u32, y: u32, color: u32) void {
    if (hal.lfbInfo()) |fb| {
        if (x >= fb.width or y >= fb.height) return; // out of bounds
        const offs: usize = @as(usize, y) * @as(usize, fb.pitch) + @as(usize, x) * 4;
        const ptr_u32: *volatile u32 = @ptrFromInt(@intFromPtr(fb.base) + offs);
        ptr_u32.* = color; // little-endian write to XRGB8888
    }
}

pub const DRIVER = reg.DriverVTable{ .name = "vesa_lfb", .probe = probe, .attach = attach };
