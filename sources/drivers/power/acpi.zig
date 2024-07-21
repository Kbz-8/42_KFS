const kernel = @import("kernel");
const libk = @import("libk");
const rsdt = @import("rsdt.zig");
const xsdt = @import("xsdt.zig");

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

var ACPI_init: bool = false;

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

fn getRSDP() !*u32
{
    kernel.logs.klogln("[ACPI] searching RSDT or XSDT...");
    var addr: u32 = 0x000E0000;
    // Search below the 1MB mark for RSDP signature
    while(addr < 0x00100000)
    {
        if(rsdt.checkRSDP(@ptrFromInt(addr))) |rsdp|
        {
            kernel.logs.klog("[ACPI] found RSDP at address 0x");
            kernel.logs.klogNb(addr);
            kernel.logs.klog("\n");
            return rsdp;
        }
        else |err|
        {
            if(err == error.RSDPNotFound)
                addr += 0x10 / @sizeOf(u32)
            else if(err == error.UseXSDT)
            {
                if(xsdt.checkXSDP(@ptrFromInt(addr))) |xsdp|
                {
                    kernel.logs.klog("[ACPI] found XSDT at address 0x");
                    kernel.logs.klogNb(addr);
                    kernel.logs.klog("\n");
                    return xsdp;
                }
                else |err2|
                {
                    if(err2 == error.XSDPNotFound)
                        addr += 0x10 / @sizeOf(u32);
                }
            }
        }
    }
    // Calculate linear address from EBDA segment
    const ebda_segment = @as(usize, @as(*const u16, @ptrFromInt(0x40E)).*);
    const ebda_linear_address = ebda_segment * 0x10 & 0x000FFFFF;
    // Search Extended BIOS Data Area for the Root System Description Pointer signature
    addr = ebda_linear_address;
    while(addr < ebda_linear_address + 1024)
    {
        if(rsdt.checkRSDP(&addr)) |rsdp|
        {
            kernel.logs.klog("[ACPI] found RSDT in EBDA at address 0x");
            kernel.logs.klogNb(addr);
            kernel.logs.klog("\n");
            return rsdp;
        }
        else |err|
        {
            if(err == error.RSDPNotFound)
                addr += 0x10 / @sizeOf(@TypeOf(addr))
            else if(err == error.UseXSDT)
            {
                if(xsdt.checkXSDP(@ptrFromInt(addr))) |xsdp|
                {
                    kernel.logs.klog("[ACPI] found XSDT in EDBA at address 0x");
                    kernel.logs.klogNb(addr);
                    kernel.logs.klog("\n");
                    return xsdp;
                }
                else |err2|
                {
                    if(err2 == error.XSDPNotFound)
                        addr += 0x10 / @sizeOf(u32);
                }
            }
        }
    }
    return error.RSDPNotFound;
}

fn checkHeader(ptr: *u32, sig: []const u8) bool
{
    if(libk.memory.memcmp(@as([*]u8, @ptrCast(ptr)), @as([*]u8, @ptrCast(@constCast(sig))), 4) != 0)
        return false;
    var check_ptr: [*]u8 = @ptrCast(ptr);
    var len: usize = @as(*usize, @ptrFromInt(@intFromPtr(ptr) + 1)).*;
    var check: u32 = 0;
    while(len > 0)
    {
        check += check_ptr[0];
        check_ptr += 1;
        len -= 1;
    }
    return (@as(u8, @truncate(check)) == 0);
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
    kernel.logs.klogln("[ACPI] loading...");
    var ptr: *u32 = getRSDP() catch |err|
    {
        if(err == error.RSDPNotFound)
            kernel.logs.klogln("[ACPI] no RSDP or XSDP found");
        return false;
    };
    if(checkHeader(ptr, "RSDT") or checkHeader(ptr, "XSDT"))
    {
        var entries: i32 = @intCast((@as(*const u32, @ptrFromInt(@intFromPtr(ptr) + 1))).*);
        entries = @divFloor((entries - 36), 4);
        ptr = @ptrFromInt(@intFromPtr(ptr) + (36 / 4)); // Skip header information

        while(entries > 0)
        {
            if(checkHeader(ptr, "FACP"))
            {
                entries = -2;
                const facp: FACP = @as(*FACP, @ptrCast(ptr)).*;
                if(checkHeader(facp.DSDT, "DSDT"))
                {
                    var S5_addr: [*]u8 = @ptrFromInt(@intFromPtr(facp.DSDT) + 36); // Skip header
                    var dsdt_length: u32 = (@as(*const u32, @ptrFromInt(@intFromPtr(facp.DSDT) + 1))).* - 36;
                    while(dsdt_length > 0)
                    {
                        if(libk.memory.memcmp(S5_addr, "_S5_", 4) == 0)
                            break;
                        S5_addr += 1;
                        dsdt_length -= 1;
                    }
                    if(dsdt_length > 0)
                    {
                        if((@as(*u8, @ptrFromInt(@intFromPtr(S5_addr) - 1)).* == 0x08 or
                                (@as(*u8, @ptrFromInt(@intFromPtr(S5_addr) - 2)).* == 0x08 and @as(*u8, @ptrFromInt(@intFromPtr(S5_addr) - 1)).* == '\\'))
                            and @as(*u8, @ptrFromInt(@intFromPtr(S5_addr) + 4)).* == 0x12)
                        {
                            S5_addr += 5;
                            S5_addr += (((S5_addr[0] & 0xC0) >> 6) + 2); // Calculate PkgLength size

                            if(S5_addr[0] == 0x0A)
                                S5_addr += 1; // Skip byte prefix
                            SLP_TYPa = @as(u16, S5_addr[0]) << 10;
                            S5_addr += 1;

                            if(S5_addr[0] == 0x0A)
                                S5_addr += 1; // Skip byte prefix
                            SLP_TYPb = @as(u16, S5_addr[0]) << 10;

                            SMI_CMD = facp.SMI_CMD;
                            ACPI_ENABLE = facp.ACPI_DISABLE;
                            ACPI_DISABLE = facp.ACPI_DISABLE;
                            PM1a_CNT = facp.PM1a_CNT_BLK;
                            PM1b_CNT = facp.PM1b_CNT_BLK;
                            PM1_CNT_LEN = facp.PM1_CNT_LEN;

                            SLP_EN = 1 << 13;
                            SCI_EN = 1;

                            kernel.logs.klogln("[ACPI] loaded");
                            ACPI_init = true;
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
        kernel.logs.klogln("[ACPI] No RSDT found");
    return false;
}

pub fn powerOff() void
{
    if(!ACPI_init || SCI_EN == 0)
        return;
    enable();
    kernel.arch.ports.out(u16, @as(u32, PM1a_CNT.*), SLP_TYPa | SLP_EN);
    if(PM1b_CNT != null)
        kernel.arch.ports.out(@as(u32, PM1b_CNT.*), SLP_TYPb | SLP_EN);
    kernel.logs.klogln("[ACPI] PowerOFF failed");
}
