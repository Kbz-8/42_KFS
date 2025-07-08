const kernel = @import("kernel");
const rsdt = @import("rsdt.zig");

pub const XSDP = extern struct {
    rspd: rsdt.RSDP,
    length: u32,
    xsdt_address: u32, // cast to u32 on IA-32
    extented_checksum: u8,
    reserved: [3]u8,
};

pub fn checkXSDP(ptr: *u32) !*u32 {
    kernel.logs.klogNb(@sizeOf(rsdt.RSDP));
    kernel.logs.klog("\n");
    kernel.logs.klogNb(@sizeOf(XSDP));
    kernel.logs.klog("\n");
    const xsdp: *XSDP = @as(*XSDP, @ptrCast(ptr));
    var check: u32 = 0;
    // Check checksum of xsdp
    const bptr: [*]u8 = @ptrCast(ptr);
    for (@sizeOf(rsdt.RSDP)..@sizeOf(XSDP)) |i|
        check += bptr[i]; // Possible kernel panic if overflow here
    kernel.logs.klogNb(check);
    kernel.logs.klog("caca\n");
    if (@as(u8, @truncate(check)) == 0)
        return @ptrFromInt(xsdp.xsdt_address);
    return error.XSDPNotFound;
}
