const std = @import("std");
const cfg = @import("../config.zig");

pub const Writer = struct {
    writeFn: *const fn (ctx: ?*anyopaque, bytes: []const u8) anyerror!usize,
    ctx: ?*anyopaque,

    pub fn write(self: *const Writer, bytes: []const u8) !usize {
        return self.writeFn(self.ctx, bytes);
    }
};

var sinks: [cfg.Config.print_sinks]?Writer = .{null} ** cfg.Config.print_sinks;
var sink_count: usize = 0;

pub fn addSink(w: Writer) void {
    if (sink_count < sinks.len) {
        sinks[sink_count] = w;
        sink_count += 1;
    }
}

pub fn print(comptime fmt: []const u8, args: anytype) void {
    if (!cfg.Config.enable_logs)
        return;
    var buf: [512]u8 = undefined;
    const s = std.fmt.bufPrint(&buf, fmt, args) catch return;
    for (sinks[0..sink_count]) |maybe_w| {
        if (maybe_w) |w|
            _ = w.write(s) catch {};
    }
}

pub fn println(comptime fmt: []const u8, args: anytype) void {
    print(fmt ++ "\n", args);
}
