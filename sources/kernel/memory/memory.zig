pub fn find(comptime T: type, haystack: []const T, needle: T) bool
{
    for(haystack) |thing|
    {
        if(thing == needle)
            return true;
    }
    return false;
}

pub fn eql(comptime T: type, a: []const T, b: []const T) bool
{
    if(a.len != b.len)
        return false;
    if(a.ptr == b.ptr)
        return true;
    for(a, b) |a_elem, b_elem|
    {
        if(a_elem != b_elem)
            return false;
    }
    return true;
}

pub fn memcmp(lhs: [*]const u8, rhs: [*]const u8, sz: usize) i32
{
    var i: usize = 0;
    while(i < sz) : (i += 1)
    {
        const comp = @as(c_int, lhs[i]) -% @as(c_int, rhs[i]);
        if(comp != 0)
            return comp;
    }
    return 0;
}

test "memcmp"
{
    const expect = @import("std").testing.expect;
    const arr0 = [_]u8{ 1, 1, 1 };
    const arr1 = [_]u8{ 1, 1, 1 };
    const arr2 = [_]u8{ 1, 0, 1 };
    const arr3 = [_]u8{ 1, 2, 1 };
    const arr4 = [_]u8{ 1, 0xff, 1 };

    try expect(memcmp(&arr0, &arr1, 3) == 0);
    try expect(memcmp(&arr0, &arr2, 3) > 0);
    try expect(memcmp(&arr0, &arr3, 3) < 0);

    try expect(memcmp(&arr0, &arr4, 3) < 0);
    try expect(memcmp(&arr4, &arr0, 3) > 0);
}
