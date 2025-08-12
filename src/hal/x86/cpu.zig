pub fn cpuid(eax: u32, ecx: u32) struct { eax: u32, ebx: u32, ecx: u32, edx: u32 } {
    var a: u32 = eax;
    var b: u32 = undefined;
    var c: u32 = ecx;
    var d: u32 = undefined;
    asm volatile (
        \\ cpuid
        : [a] "=a" (a),
          [b] "=b" (b),
          [c] "=c" (c),
          [d] "=d" (d),
        : [a] "a" (a),
          [c] "c" (c),
    );
    return .{ .eax = a, .ebx = b, .ecx = c, .edx = d };
}
