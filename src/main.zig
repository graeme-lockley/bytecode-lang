const std = @import("std");
const Op = @import("./ops.zig").Op;

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

        _ = try Interpreter.eval(allocator, buffer);
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

fn eval(code: []const u8) !i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const err = gpa.deinit();
        if (err == std.heap.Check.leak) {
            stdout.print("Failed to deinit allocator\n", .{}) catch {};
            std.process.exit(1);
        }
    }

    return try Interpreter.eval(allocator, code);
}

const expectEqual = std.testing.expectEqual;

test "EQI - success" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.EQI),
    };

    try expectEqual(1, eval(&code));
}

test "EQI - failure" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.EQI),
    };

    try expectEqual(0, eval(&code));
}

test "NEQI - success" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.NEQI),
    };

    try expectEqual(1, eval(&code));
}

test "NEQI - failure" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.NEQI),
    };

    try expectEqual(0, eval(&code));
}

test "LTI - 1 < 2" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.LTI),
    };

    try expectEqual(1, eval(&code));
}

test "LTI - 2 < 1" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.LTI),
    };

    try expectEqual(0, eval(&code));
}

test "LTI - 1 < 1" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.LTI),
    };

    try expectEqual(0, eval(&code));
}

test "LEI - 1 <= 2" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.LEI),
    };

    try expectEqual(1, eval(&code));
}

test "LEI - 2 <= 1" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.LEI),
    };

    try expectEqual(0, eval(&code));
}

test "LEI - 1 <= 1" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.LEI),
    };

    try expectEqual(1, eval(&code));
}

test "GTI - 1 > 2" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.GTI),
    };

    try expectEqual(0, eval(&code));
}

test "GTI - 2 > 1" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.GTI),
    };

    try expectEqual(1, eval(&code));
}

test "GTI - 1 > 1" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.GTI),
    };

    try expectEqual(0, eval(&code));
}

test "GEI - 1 >= 2" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.GEI),
    };

    try expectEqual(0, eval(&code));
}

test "GEI - 2 >= 1" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.GEI),
    };

    try expectEqual(1, eval(&code));
}

test "GEI - 1 >= 1" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.GEI),
    };

    try expectEqual(1, eval(&code));
}

test "ADDI op" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI), 0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.ADDI),
    };

    try expectEqual(3, eval(&code));
}

test "MULTIPLYI op" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI),     0x05, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI),     0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.MULTIPLYI),
    };

    try expectEqual(10, eval(&code));
}

test "DIVIDEI op" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI),   0x05, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI),   0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.DIVIDEI),
    };

    try expectEqual(2, eval(&code));
}

test "MODULUSI op" {
    const code = [11]u8{
        @intFromEnum(Op.PUSHI),    0x05, 0x00, 0x00, 0x00,
        @intFromEnum(Op.PUSHI),    0x02, 0x00, 0x00, 0x00,
        @intFromEnum(Op.MODULUSI),
    };

    try expectEqual(1, eval(&code));
}

test "STOREG" {
    const code = [26]u8{
        @intFromEnum(Op.PUSHI), 0x05, 0x00, 0x00, 0x00, // 5
        @intFromEnum(Op.PUSH), 0x00, 0x00, 0x00, 0x00, // 0
        @intFromEnum(Op.PUSHI), 0x06, 0x00, 0x00, 0x00, // 6
        @intFromEnum(Op.ADDI),
        @intFromEnum(Op.STORE), 0x00, 0x00, 0x00, 0x00, // 0
        @intFromEnum(Op.PUSH), 0x00, 0x00, 0x00, 0x00, // 0
    };

    try expectEqual(11, eval(&code));
}

test "inc" {
    const code = [36]u8{
        @intFromEnum(Op.JMP), 0x1a, 0x00, 0x00, 0x00, // 26
        @intFromEnum(Op.PUSHL), 0x00, 0x00, 0x00, 0x00, // 0
        @intFromEnum(Op.PUSHI), 0x01, 0x00, 0x00, 0x00, // 1
        @intFromEnum(Op.ADDI),
        @intFromEnum(Op.STOREL), 0x01, 0x00, 0x00, 0x00, // 1
        @intFromEnum(Op.RET), 0x01, 0x00, 0x00, 0x00, // 1
        @intFromEnum(Op.PUSHI), 0x29, 0x00, 0x00, 0x00, // 41
        @intFromEnum(Op.CALL), 0x05, 0x00, 0x00, 0x00, // 5
    };

    try expectEqual(42, eval(&code));
}
