pub const toString = @import("to_string.zig").toString;
pub const toStringBase = @import("to_string.zig").toStringBase;
pub const toStringBuffer = @import("to_string.zig").toStringBuffer;
pub const toStringBufferBase = @import("to_string.zig").toStringBufferBase;

pub fn strlen(ptr: [*]const u8) usize
{
    var count: usize = 0;
    while(ptr[count] != 0) : (count += 1) {}
    return count;
}

pub fn streql(a: []const u8, b: []const u8) bool
{
    if(a.len != b.len)
        return false;
    for(a, 0..) |item, index|
    {
        if(b[index] != item)
            return false;
    }
    return true;
}

pub fn streqlnt(a: []const u8, b: []const u8) bool
{
    const len: usize = if(a.len >= b.len) a.len else b.len;
    for(0..len) |i|
    {
        if(a[i] == 0 or b[i] == 0)
            return true;
        if(a[i] != b[i])
            return false;
    }
    return true;
}

test "strlen"
{
    const expect = @import("std").testing.expect;
    const str0 = "this is a string";
    const str1 = "";
    const str2 = "yes";
    const str3 = "string";

    try expect(strlen(str0) == 16);
    try expect(strlen(str1) == 0);
    try expect(strlen(str2) == 3);
    try expect(strlen(str3) == 6);
}

test "streql"
{
    const expect = @import("std").testing.expect;
    const str0 = "this is a string";
    const str1 = "";
    const str2 = "string";
    const str3 = "string";

    try expect(streql(str0, str1) == false);
    try expect(streql(str1, str2) == false);
    try expect(streql(str2, str3) == true);
    try expect(streql(str3, "string") == true);
}
