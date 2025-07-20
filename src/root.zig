const std = @import("std");

pub fn CompareString(a: []const u8, b: []const u8) bool {
    if (a.len != b.len)
        return false;
    if (a.ptr == b.ptr)
        return true;
    for (a, b) |aElem, bElem| {
        if (aElem != bElem) return false;
    }
    return true;
}
