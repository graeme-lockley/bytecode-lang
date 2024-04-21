const std = @import("std");

const BCInterpreter = @import("./bc-interpreter.zig");
const Errors = @import("./errors.zig");
const Runtime = @import("./runtime.zig").Runtime;
const V = @import("./value.zig");

const Editor = @import("zigline/main.zig").Editor;

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

    var args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len == 4) {} else {
        try stdout.print("Error: Incorrect number of arguments.\n", .{});

        try stdout.print("Usage: {s} [ast] iterations file\n", .{args[0]});
        std.process.exit(1);
    }
}

pub fn expectExprEqual(input: []const u8, expected: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();

    {
        _ = input;
        _ = expected;
    }

    const err = gpa.deinit();
    if (err == std.heap.Check.leak) {
        std.log.err("Failed to deinit allocator\n", .{});
        return error.TestingError;
    }
}

fn expectError(input: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();

    {
        _ = input;
    }

    var err = gpa.deinit();
    if (err == std.heap.Check.leak) {
        std.log.err("Failed to deinit allocator\n", .{});
        return error.TestingError;
    }
}

const expectEqual = std.testing.expectEqual;

test "assignment expression" {}
