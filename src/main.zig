const std = @import("std");

const Interpreter = @import("./interpreter.zig");

const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const err = gpa.deinit();
        if (err == std.heap.Check.leak) {
            stdout.print("Failed to deinit allocator\n", .{}) catch {};
            std.process.exit(1);
        }
    }

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len == 2) {
        const fileName = args[1];

        const buffer = try loadBinary(allocator, fileName);
        defer allocator.free(buffer);

        try Interpreter.eval(allocator, buffer);
    } else if (args.len == 3) {
        // const iterations = try std.fmt.parseInt(usize, args[1], 10);
        unreachable;
    } else {
        try stdout.print("Error: Incorrect number of arguments.\n", .{});

        try stdout.print("Usage: {s} [iterations] file\n", .{args[0]});
        std.process.exit(1);
    }
}

fn loadBinary(allocator: std.mem.Allocator, fileName: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();

    const fileSize = try file.getEndPos();
    const buffer: []u8 = try file.readToEndAlloc(allocator, fileSize);

    return buffer;
}
