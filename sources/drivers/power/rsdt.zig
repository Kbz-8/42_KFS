const kernel = @import("kernel");
const libk = @import("libk");

pub const RSDP = struct
{
    signature: [8]u8,
    checksum: u8,
    oem_id: [6]u8,
    revision: u8,
    rsdt_address: u32,
};

pub fn checkRSDP(ptr: *u32) !*u32
{
    const rsdp: *RSDP = @as(*RSDP, @ptrCast(ptr));
    const sig = "RSD PTR ";
    var check: u32 = 0;
    if(libk.memory.memcmp(sig, @as([*]u8, @ptrCast(rsdp)), 8) == 0)
    {
        // Check checksum of rsdp
        const bptr: [*]u8 = @ptrCast(ptr);
        for(0..@sizeOf(RSDP)) |i|
            check += bptr[i]; // Possible kernel panic if overflow here
        if(@as(u8, @truncate(check)) == 0)
        {
            if(rsdp.revision == 0)
                return @ptrFromInt(rsdp.rsdt_address);
            return error.UseXSDT;
        }
    }
    return error.RSDPNotFound;
}

