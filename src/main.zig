const std = @import("std");
const lwe = @import("lwe_lib");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
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
        if (lwe.CompareString(user, "help")) {
            try HelpSombody();
        } else if (lwe.CompareString(user, "exit")) {
            try stdout.print("quiting a program with save", .{});
            try FromFile();
            std.process.exit(0);
        } else if (lwe.CompareString(user, "add")) {
            try AddGame(&list);
        } else if (lwe.CompareString(user, "list")) {
            try ListTool(&list);
        } else if (lwe.CompareString(user, "change")) {
            try ChangeOrder(&list);
        } else if (lwe.CompareString(user, "remove")) {
            try RemoveGame(&list);
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

pub fn RemoveGame(list: *ArrayList([]const u8)) !void {
    if (list.items.len == 0) {
        try stdout.print("nothing to remove", .{});
        return;
    }
    var bufferin: [1024]u8 = undefined;
    try ListTool(list);
    try stdout.print("write what of nodes you want to remove: \n", .{});
    const removegame = try stdin.readUntilDelimiter(&bufferin, '\n');
    if (lwe.CompareString(removegame, "no")) {
        try stdout.print("ok, i removed nothing \n", .{});
        return;
    }
    for (list.items, 0..) |name, index| {
        if (lwe.CompareString(removegame, name)) {
            _ = list.orderedRemove(index);
            return;
        }
    }
    try stdout.print("ups, i don't recognize what you want to remove", .{});
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

pub fn ToFile(list: *ArrayList([]const u8)) !void {
    var file = try std.fs.cwd().createFile("list.json", .{});
    defer file.close();
    for (list.items) |value| {
        try file.writeAll(value);
        try file.writeAll(" ");
    }
}

pub fn FromFile() !void {
    var file = try std.fs.cwd().openFile("list.json", .{});
    defer file.close();
    var buffer: [1024]u8 = undefined;
    const readed = try file.reader().read(&buffer);
    try stdout.print("{any}", .{});
}

pub fn HelpSombody() !void {
    try stdout.print("add -- for a new game, \nexit -- exit the loop \nlist -- for a list, \nchange -- for changing order of games, \nhelp -- you are reading this\nremove -- removes node that you input\n", .{});
}
