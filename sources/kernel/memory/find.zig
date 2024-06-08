pub fn find(comptime T: type, haystack: []const T, needle: T) bool
{
    for(haystack) |thing|
    {
        if(thing == needle)
            return true;
    }
    return false;
}
