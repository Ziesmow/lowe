const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
const String = @import("./zig-string.zig").String;
const ArrayList = std.ArrayList;

pub fn main() !void {
    try stdout.print("welcome into your list manager, löwe \n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = ArrayList([]const u8).init(allocator);
    try stdout.print("what you want to do \n", .{});
    defer list.deinit();
    var bufferin: [1024]u8 = undefined;
    while (true) {
        try stdout.print(">>> ", .{});
        const user = try stdin.readUntilDelimiter(&bufferin, '\n');
        if (CompareString(user, "help")) {
            try HelpSombody();
        } else if (CompareString(user, "exit")) {
            try stdout.print("quiting a program with save", .{});
            std.process.exit(0);
        } else if (CompareString(user, "add")) {
            try AddGame(&list);
        } else if (CompareString(user, "list")) {
            try ListTool(&list);
        } else if (CompareString(user, "change")) {
            try ChangeOrder(&list);
        } else {
            try stdout.print("don't recognize it \n", .{});
        }
    }
}

pub fn AddGame(list: *ArrayList([]const u8)) !void {
    var bufferin: [1024]u8 = undefined;
    try stdout.print("podaj nazwę nowego węzła: \n", .{});
    const newgamename = try stdin.readUntilDelimiter(&bufferin, '\n');
    const allocator = list.allocator;
    const copy = try allocator.dupe(u8, newgamename);
    try list.append(copy);
}

pub fn ListTool(list: *ArrayList([]const u8)) !void {
    for (list.items, 0..) |item, index| {
        try stdout.print("{d} ---- {s}\n", .{ index, item });
    }
}

pub fn ChangeOrder(list: *ArrayList([]const u8)) !void {
    var bufferin: [1024]u8 = undefined;
    try ListTool(list);
    try stdout.print("what position change ? \n:", .{});
    const gameintSTR = try stdin.readUntilDelimiter(&bufferin, '\n');
    const gameint = try std.fmt.parseInt(usize, gameintSTR, 10);
    try stdout.print("destination ? \n:", .{});
    const newpositionSTR = try stdin.readUntilDelimiter(&bufferin, '\n');
    const newposition = try std.fmt.parseInt(usize, newpositionSTR, 10);
    if (gameint == newposition or gameint >= list.items.len or newposition >= list.items.len) {
        return;
    }
    const temp: []const u8 = list.items[gameint];
    if (gameint < newposition) {
        var i = gameint;
        while (i < newposition) : (i += 1) {
            list.items[i] = list.items[i + 1];
        }
    } else {
        var i = gameint;
        while (i > newposition) : (i -= 1) {
            list.items[i] = list.items[i - 1];
        }
    }
    list.items[newposition] = temp;
    try ListTool(list);
}

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

pub fn HelpSombody() !void {
    try stdout.print("add -- for a new game, \nexit -- exit the loop \nlist -- for a list, \nchange -- for changing order of games, \nhelp -- you are reading this\n", .{});
}
