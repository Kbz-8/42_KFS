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

pub fn configureLfb(base: usize, w: u32, h: u32, pitch: u32) void {
    arch.video.configureLfb(base, w, h, pitch);
}
