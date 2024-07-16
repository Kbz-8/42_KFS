const kernel = @import("kernel");

var SMI_CMD: ?*u32 = null;
var ACPI_ENABLE: u8 = 0;
var ACPI_DISABLE: u8 = 0;
var PM1a_CNT: ?*u32 = null;
var PM1b_CNT: ?*u32 = null;
var SLP_TYPa: u16 = 0;
var SLP_TYPb: u16 = 0;
var SLP_EN: u16 = 0;
var SCI_EN: u16 = 0;
var PM1_CNT_LEN: u8 = 0;

const RSDP = struct
{
    signature: [8]u8,
    checksum: u8,
    oem_id: [6]u8,
    revision: u8,
    rsdt_address: *u32,
};

const FACP = struct
{
    signature: [4]u8,
    length: u32,
    unneeded1: [40 - 8]u8,
    DSDT: *u32,
    unneeded2: [48 - 44]u8,
    SMI_CMD: *u32,
    ACPI_ENABLE: u8,
    ACPI_DISABLE: u8,
    unneeded3: [64 - 54]u8,
    PM1a_CNT_BLK: *u32,
    PM1b_CNT_BLK: *u32,
    unneeded4: [89 - 72]u8,
    PM1_CNT_LEN: u8,
};

fn checkRSDP(ptr: *u32) !*u32
{
    const rsdp: *RSDP = @as(*RSDP, @ptrCast(ptr));
    const sig = "RSD PTR ";
    var check: u32 = 0;

    if(kernel.memory.memcmp(sig, @as([*]u8, @ptrCast(rsdp)), 8) == 0)
    {
        // Check checksum of rsdp
        const bptr: [*]u8 = @ptrCast(ptr);
        for(0..@sizeOf(RSDP)) |i|
            check += bptr[i];
        // Found valid rsdp
        if(@as(u8, @truncate(check)) == 0)
            return rsdp.rsdt_address;
    }
    return error.RSDPNotFound;
}

fn getRSDP() !*u32
{
    var addr: u32 = 0x000E0000;
    // Search below the 1MB mark for RSDP signature
    while(addr < 0x00100000)
    {
        if(checkRSDP(@ptrFromInt(addr))) |rsdp|
        {
            kernel.logs.klogln("[ACPI] found RSDP");
            return rsdp;
        }
        else |err|
        {
            if(err == error.RSDPNotFound)
                addr += 0x10 / @sizeOf(u32);
        }
    }

    kernel.logs.klogln("2nd loop");
    // Calculate linear address from EBDA segment
    const ebda_segment = @as(usize, ((@as(*const u16, @ptrFromInt(0x40E))).*));
    const ebda_linear_address = ebda_segment * 0x10 & 0x000FFFFF;

    // Search Extended BIOS Data Area for the Root System Description Pointer signature
    addr = ebda_linear_address;
    while(addr < ebda_linear_address + 1024)
    {
        if(checkRSDP(&addr)) |rsdp|
        {
            kernel.logs.klogln("[ACPI] found RSDP");
            return rsdp;
        }
        else |err|
        {
            if(err == error.RSDPNotFound)
                addr += 0x10 / @sizeOf(@TypeOf(addr));
        }
    }

    return error.RSDPNotFound;
}

fn checkHeader(ptr: [*]u8, sig: []const u8) bool
{
    if(kernel.memory.memcmp(ptr, @as([*]u8, @ptrCast(@constCast(sig))), 4) == 0)
    {
        var check_ptr: [*]u8 = ptr;
        var len: u16 = @intCast(@as(*const u16, @ptrFromInt(@intFromPtr(ptr) + 1)).*);
        var check: u8 = 0;
        while(len > 0)
        {
            check += check_ptr[0];
            check_ptr += 1;
            len -= 1;
        }
        if(check == 0)
            return true;
    }
    return false;
}

fn enable() i32
{
    // Check if ACPI is enabled
    if(((kernel.arch.ports.in(u16, PM1a_CNT)) & SCI_EN) == 0)
    {
        // Check if ACPI can be enabled
        if(SMI_CMD != null and ACPI_ENABLE != 0)
        {
            kernel.arch.ports.out(u8, SMI_CMD.*, ACPI_ENABLE); // Send ACPI enable command
            // Give 3 seconds time to enable ACPI
            var i: u32 = 0;
            while(i < 300)
            {
                if(((kernel.arch.ports.in(u16, PM1a_CNT)) & SCI_EN) == 1)
                    break;
                i += 1;
            }
            if(PM1b_CNT != null)
            {
                while(i < 300)
                {
                    if(((kernel.arch.ports.in(u16, PM1b_CNT)) & SCI_EN) == 1)
                        break;
                    i += 1;
                }
            }
            if(i < 300)
            {
                kernel.logs.klogln("[ACPI] Enabled");
                return 0;
            }
            else
            {
                kernel.logs.klogln("[ACPI] Couldn't enable");
                return -1;
            }
        }
        else
        {
            kernel.logs.klogln("[ACPI] Impossible to enable");
            return -1;
        }
    }
    else // ACPI was already enabled
        return 0;
}

pub fn init() bool
{
    @setRuntimeSafety(false);

    kernel.logs.klogln("[ACPI] loading...");
    var ptr: *u32 = getRSDP() catch |err|
    {
        if(err == error.RSDPNotFound)
            kernel.logs.klogln("[ACPI] could not find RSDP address");
        return false;
    };

    if(checkHeader(@ptrCast(ptr), "RSDT"))
    {
        var entries: i32 = @intCast((@as(*const u32, @ptrFromInt(@intFromPtr(ptr) + 1))).*);
        entries = @divFloor((entries - 36), 4);
        ptr = @ptrFromInt(@intFromPtr(ptr) + (36 / 4)); // Skip header information

        while(entries > 0)
        {
            if(checkHeader(@as([*]u8, @ptrCast(ptr)), "FACP"))
            {
                entries = -2;
                const facp: FACP = @as(*FACP, @ptrCast(ptr)).*;
                if(checkHeader(@as([*]u8, @ptrCast(facp.DSDT)), "DSDT"))
                {
                    var S5Addr: [*]u8 = @ptrFromInt(@intFromPtr(facp.DSDT) + 36); // Skip header
                    var dsdtLength: u32 = (@as(*const u32, @ptrFromInt(@intFromPtr(facp.DSDT) + 1))).* - 36;
                    while(dsdtLength > 0)
                    {
                        if(kernel.memory.memcmp(S5Addr, "_S5_", 4) == 0)
                            break;
                        S5Addr += 1;
                        dsdtLength -= 1;
                    }
                    if(dsdtLength > 0)
                    {
                        if((@as(*u8, @ptrFromInt(@intFromPtr(S5Addr) - 1)).* == 0x08 or
                                (@as(*u8, @ptrFromInt(@intFromPtr(S5Addr) - 2)).* == 0x08 and @as(*u8, @ptrFromInt(@intFromPtr(S5Addr) - 1)).* == '\\'))
                            and @as(*u8, @ptrFromInt(@intFromPtr(S5Addr) + 4)).* == 0x12)
                        {
                            S5Addr += 5;
                            S5Addr += (((S5Addr[0] & 0xC0) >> 6) + 2); // Calculate PkgLength size

                            if(S5Addr[0] == 0x0A)
                                S5Addr += 1; // Skip byte prefix
                            SLP_TYPa = @as(u16, S5Addr[0]) << 10;
                            S5Addr += 1;

                            if(S5Addr[0] == 0x0A)
                                S5Addr += 1; // Skip byte prefix
                            SLP_TYPb = @as(u16, S5Addr[0]) << 10;

                            SMI_CMD = facp.SMI_CMD;
                            ACPI_ENABLE = facp.ACPI_DISABLE;
                            ACPI_DISABLE = facp.ACPI_DISABLE;
                            PM1a_CNT = facp.PM1a_CNT_BLK;
                            PM1b_CNT = facp.PM1b_CNT_BLK;
                            PM1_CNT_LEN = facp.PM1_CNT_LEN;

                            SLP_EN = 1 << 13;
                            SCI_EN = 1;

                            kernel.logs.klogln("[ACPI] loaded");
                            return true;
                        }
                        else
                            kernel.logs.klogln("[ACPI] \\_S5 parse error");
                    }
                    else
                        kernel.logs.klogln("[ACPI] \\_S5 not present");
                }
                else
                    kernel.logs.klogln("[ACPI] DSDT invalid");
            }
            ptr = @ptrFromInt(@intFromPtr(ptr) + 1);
        }
        kernel.logs.klogln("[ACPI] no valid FACP present");
    }
    else
        kernel.logs.klogln("[ACPO] No ACPI found");
    return false;
}

pub fn powerOff() void
{
    if(SCI_EN == 0)
        return;

    enable();
    kernel.arch.ports.out(u16, @as(u32, PM1a_CNT.*), SLP_TYPa | SLP_EN);
    if(PM1b_CNT != null)
        kernel.arch.ports.out(@as(u32, PM1b_CNT.*), SLP_TYPb | SLP_EN);
    kernel.logs.klogln("[ACPI] PowerOFF failed");
}
