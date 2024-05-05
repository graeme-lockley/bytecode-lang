const std = @import("std");

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

    if (args.len == 4) {
        try stdout.print("We are here.\n", .{});
    } else {
        try stdout.print("Error: Incorrect number of arguments.\n", .{});

        try stdout.print("Usage: {s} [ast] iterations file\n", .{args[0]});
        std.process.exit(1);
    }
}
