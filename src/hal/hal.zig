const builtin = @import("builtin");

comptime {
    if (!builtin.is_test) {
        switch (builtin.cpu.arch) {
            .x86 => _ = @import("x86/boot.zig"),
            else => unreachable,
        }
    }
}

pub const arch = if (!builtin.is_test) switch (builtin.cpu.arch) {
    .x86 => @import("x86/x86.zig"),
    else => unreachable,
} else unreachable;

// Video mode control (VGA text vs VESA LFB)
pub const VideoMode = arch.video.VideoMode;

pub fn setVideoMode(mode: VideoMode) !void {
    return arch.video.setVideoMode(mode);
}

pub fn configureLfb(base: u32, w: u32, h: u32, pitch: u32) void {
    arch.video.configureLfb(base, w, h, pitch);
}

pub fn lfbInfo() ?struct { base: [*]volatile u8, pitch: u32, width: u32, height: u32 } {
    const maybe_lfb = arch.video.lfbInfo();
    if (maybe_lfb) |lfb| {
        return .{
            .base = lfb.base,
            .pitch = lfb.pitch,
            .width = lfb.width,
            .height = lfb.height,
        };
    }
    return null;
}

pub fn halt() void {
    arch.halt();
}
