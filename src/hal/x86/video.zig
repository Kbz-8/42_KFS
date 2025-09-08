// Simple video mode selector for VGA text vs VESA linear framebuffer (LFB).
// NOTE: Switching into a VESA mode normally requires firmware (BIOS INT 0x10)
// which is unavailable in 64-bit long mode. This HAL expects the bootloader
// to set the desired VESA mode and pass LFB info (e.g., via Multiboot2).

pub const VideoMode = enum {
    vga_text_80x25,
    vesa_lfb,
};

var current_mode: VideoMode = .vga_text_80x25;

// VGA text buffer (80x25x2 bytes) at physical 0xB8000
pub const VGA_TEXT_PHYS: usize = 0xB8000;

// VESA LFB state (configured by boot-time code)
var lfb_base: ?[*]volatile u8 = null;
var lfb_pitch: u32 = 0;
var lfb_width: u32 = 0;
var lfb_height: u32 = 0;

/// Provide the LFB parameters discovered at boot.
pub fn configureLfb(base: u32, width: u32, height: u32, pitch: u32) void {
    lfb_base = @ptrFromInt(base);
    lfb_width = width;
    lfb_height = height;
    lfb_pitch = pitch;
}

/// Attempt to switch output mode used by the kernel.
/// For VESA, the LFB must have been configured already.
pub fn setVideoMode(mode: VideoMode) !void {
    switch (mode) {
        .vga_text_80x25 => {
            current_mode = mode;
            return;
        },
        .vesa_lfb => {
            if (lfb_base == null)
                return error.NotSupported;
            current_mode = mode;
            return;
        },
    }
}

/// Optional helpers to query active framebuffer (for future console driver)
pub fn currentMode() VideoMode {
    return current_mode;
}

pub fn lfbInfo() ?struct { base: [*]volatile u8, pitch: u32, width: u32, height: u32 } {
    if (lfb_base) |b|
        return .{
            .base = b,
            .pitch = lfb_pitch,
            .width = lfb_width,
            .height = lfb_height,
        };
    return null;
}
