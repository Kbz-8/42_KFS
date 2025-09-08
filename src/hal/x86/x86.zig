pub const io = @import("io.zig");
pub const video = @import("video.zig");

pub fn halt() void {
    asm volatile ("hlt");
}
