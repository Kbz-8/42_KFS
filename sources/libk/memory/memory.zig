pub fn find(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |thing| {
        if (thing == needle)
            return true;
    }
    return false;
}

pub fn eql(comptime T: type, a: []const T, b: []const T) bool {
    if (a.len != b.len)
        return false;
    if (a.ptr == b.ptr)
        return true;
    for (a, b) |a_elem, b_elem| {
        if (a_elem != b_elem)
            return false;
    }
    return true;
}

pub fn memcmp(lhs: [*]const u8, rhs: [*]const u8, sz: usize) i32 {
    var i: usize = 0;
    while (i < sz) : (i += 1) {
        const comp = @as(i32, lhs[i]) -% @as(i32, rhs[i]);
        if (comp != 0)
            return comp;
    }
    return 0;
}

pub fn memset(dest: [*]u8, c: u8, len: usize) [*]u8 {
    if (len != 0) {
        for (0..len) |i|
            dest[i] = c;
    }
    return dest;
}

test "eql" {
    const expect = @import("std").testing.expect;
    const arr0 = [_]u8{ 1, 1, 1 };
    const arr1 = [_]u8{ 1, 1, 1 };
    const arr2 = [_]u8{ 1, 0, 1 };
    const arr3 = [_]u8{ 1, 2, 1 };

    try expect(eql(u8, &arr0, &arr1));
    try expect(!eql(u8, &arr0, &arr2));
    try expect(!eql(u8, &arr0, &arr3));
}

test "memcmp" {
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

test "memset" {
    const expect = @import("std").testing.expect;
    var arr0 = [_]u8{ 1, 1, 1 };
    var arr1 = [_]u8{ 1, 1, 1 };
    var arr2 = [_]u8{ 1, 0, 1 };
    var arr3 = [_]u8{ 1, 2, 1 };

    _ = memset(&arr0, 0, arr0.len);
    _ = memset(&arr1, 0, arr1.len);
    _ = memset(&arr2, 12, arr2.len);
    _ = memset(&arr3, 47, arr3.len);

    const res0 = [_]u8{ 0, 0, 0 };
    const res1 = [_]u8{ 12, 12, 12 };
    const res2 = [_]u8{ 47, 47, 47 };

    try expect(eql(u8, &arr0, &arr1));
    try expect(eql(u8, &arr0, &res0));
    try expect(eql(u8, &arr2, &res1));
    try expect(eql(u8, &arr3, &res2));
}
