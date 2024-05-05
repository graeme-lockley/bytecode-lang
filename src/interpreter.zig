const std = @import("std");

const Runtime = @import("./../runtime.zig").Runtime;
const Op = @import("./ops.zig").Op;

pub fn eval(allocator: std.mem.Allocator, bytecode: []const u8) !void {
    var ip: usize = 0;
    var stack = std.ArrayList(i32).init(allocator);
    defer stack.deinit();
    const stdout = std.io.getStdOut().writer();

    while (ip < bytecode.len) {
        switch (@as(Op, @enumFromInt(bytecode[ip]))) {
            .PUSH => {
                const v: usize = @intCast(readInt(bytecode, ip + 1));
                try stack.append(stack.items[v]);
                ip += 5;
            },
            .PUSHI => {
                const v = readInt(bytecode, ip + 1);
                try stack.append(v);
                ip += 5;
            },
            .PUSHS => {
                const length: usize = @intCast(readInt(bytecode, ip + 1));
                try stack.append(@intCast(ip + 1));
                ip += 5 + length;
            },
            .PRINTLN => {
                try stdout.print("\n", .{});
                ip += 1;
            },
            .PRINTB => {
                const v = stack.pop();
                if (v == 0) {
                    try stdout.print("false", .{});
                } else {
                    try stdout.print("true", .{});
                }
                ip += 1;
            },
            .PRINTI => {
                const v = stack.pop();
                try stdout.print("{d}", .{v});
                ip += 1;
            },
            .PRINTS => {
                const v = stack.pop();
                const s = readString(bytecode, @intCast(v));
                try stdout.print("{s}", .{s});
                ip += 1;
            },

            // else => {
            //     try stdout.print("Unknown opcode: {} at {d}\n", .{ bytecode[ip], ip });
            //     unreachable;
            // },
        }
    }
}

pub fn readInt(bytecode: []const u8, ip: usize) i32 {
    const v: i32 = @bitCast(@as(u32, (bytecode[ip])) |
        (@as(u32, bytecode[ip + 1]) << 8) |
        (@as(u32, bytecode[ip + 2]) << 16) |
        (@as(u32, bytecode[ip + 3]) << 24));

    return v;
}

pub fn readString(bytecode: []const u8, ip: usize) []const u8 {
    const size: usize = @intCast(readInt(bytecode, ip));
    return bytecode[ip + 4 .. ip + 4 + size];
}
