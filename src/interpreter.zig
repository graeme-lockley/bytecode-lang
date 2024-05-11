const std = @import("std");

const Runtime = @import("./../runtime.zig").Runtime;
const Op = @import("./ops.zig").Op;

pub fn eval(allocator: std.mem.Allocator, bytecode: []const u8) !i32 {
    var ip: usize = 0;
    var lbp: usize = 0;
    var stack = std.ArrayList(i32).init(allocator);
    defer stack.deinit();
    const stdout = std.io.getStdOut().writer();

    while (ip < bytecode.len) {
        switch (@as(Op, @enumFromInt(bytecode[ip]))) {
            .PUSH => {
                const v: usize = @intCast(readInt(bytecode, ip + 1));
                // std.log.debug("{d} PUSH {d} ({d})", .{ ip, v, stack.items[v] });
                try stack.append(stack.items[v]);
                ip += 5;
            },
            .PUSHL => {
                const offset = readInt(bytecode, ip + 1);
                const idx: usize = @intCast(@as(i32, @intCast(lbp)) + offset);
                const value = stack.items[idx];

                // std.log.debug("{d} PUSH {d} ({d})", .{ ip, offset, value });
                try stack.append(value);

                ip += 5;
            },
            .PUSHI => {
                const v = readInt(bytecode, ip + 1);
                // std.log.debug("{d} PUSHI {d}", .{ ip, v });

                try stack.append(v);
                ip += 5;
            },
            .PUSHS => {
                const length: usize = @intCast(readInt(bytecode, ip + 1));
                try stack.append(@intCast(ip + 1));
                // std.log.debug("{d} PUSHS {s}", .{ ip, readString(bytecode, ip + 1) });

                ip += 5 + length;
            },
            .STORE => {
                const v = stack.pop();
                const g: usize = @intCast(readInt(bytecode, ip + 1));
                // std.log.debug("{d} STORE {d} ({d})", .{ ip, g, v });
                stack.items[g] = v;
                ip += 5;
            },
            .STOREL => {
                const v = stack.pop();
                const l: usize = @intCast(readInt(bytecode, ip + 1));
                // std.log.debug("{d} STOREL {d} ({d})", .{ ip, l, v });
                stack.items[lbp + l] = v;
                ip += 5;
            },
            .CALL => {
                // std.log.debug("{d} CALL {d}", .{ ip, readInt(bytecode, ip + 1) });

                const newLBP = stack.items.len;

                try stack.append(0);
                try stack.append(@as(i32, @intCast(ip)) + 5);
                try stack.append(@intCast(lbp));

                lbp = newLBP;

                ip = @intCast(readInt(bytecode, ip + 1));
            },
            .RET => {
                const n: usize = @intCast(readInt(bytecode, ip + 1));
                // std.log.debug("{d} RET {d} (result: {d}, ip: {d}, lbp: {d})", .{ ip, n, stack.items[lbp], stack.items[lbp + 1], stack.items[lbp + 2] });

                const oldLBP = lbp;
                const r = stack.items[lbp];
                ip = @intCast(stack.items[lbp + 1]);
                lbp = @intCast(stack.items[lbp + 2]);
                stack.items.len = oldLBP - n;

                try stack.append(r);
            },
            .DISCARD => {
                _ = stack.pop();
                ip += 1;
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
                // std.log.debug("{d} PRINTI ({d})", .{ ip, v });
                try stdout.print("{d}", .{v});
                ip += 1;
            },
            .PRINTS => {
                const v = stack.pop();
                const s = readString(bytecode, @intCast(v));
                // std.log.debug("{d} PRINTS ({s})", .{ ip, s });
                try stdout.print("{s}", .{s});
                ip += 1;
            },

            .EQI => {
                const b = stack.pop();
                const a = stack.pop();
                // std.log.debug("{d} EQI ({d} {d})", .{ ip, a, b });

                if (a == b) {
                    try stack.append(1);
                } else {
                    try stack.append(0);
                }
                ip += 1;
            },
            .NEQI => {
                const b = stack.pop();
                const a = stack.pop();
                // std.log.debug("{d} NEQI ({d} {d})", .{ ip, a, b });

                if (a != b) {
                    try stack.append(1);
                } else {
                    try stack.append(0);
                }
                ip += 1;
            },
            .LTI => {
                const b = stack.pop();
                const a = stack.pop();
                // std.log.debug("{d} LTI ({d} {d})", .{ ip, a, b });

                if (a < b) {
                    try stack.append(1);
                } else {
                    try stack.append(0);
                }
                ip += 1;
            },
            .LEI => {
                const b = stack.pop();
                const a = stack.pop();
                // std.log.debug("{d} LEI ({d} {d})", .{ ip, a, b });

                if (a <= b) {
                    try stack.append(1);
                } else {
                    try stack.append(0);
                }
                ip += 1;
            },
            .GTI => {
                const b = stack.pop();
                const a = stack.pop();
                // std.log.debug("{d} GTI ({d} {d})", .{ ip, a, b });

                if (a > b) {
                    try stack.append(1);
                } else {
                    try stack.append(0);
                }
                ip += 1;
            },
            .GEI => {
                const b = stack.pop();
                const a = stack.pop();
                // std.log.debug("{d} GEI ({d} {d})", .{ ip, a, b });

                if (a >= b) {
                    try stack.append(1);
                } else {
                    try stack.append(0);
                }
                ip += 1;
            },

            .ADDI => {
                const b = stack.pop();
                const a = stack.pop();
                try stack.append(a + b);
                ip += 1;
            },
            .SUBTRACTI => {
                const b = stack.pop();
                const a = stack.pop();
                try stack.append(a - b);
                ip += 1;
            },
            .MULTIPLYI => {
                const b = stack.pop();
                const a = stack.pop();
                try stack.append(a * b);
                ip += 1;
            },
            .DIVIDEI => {
                const b = stack.pop();
                const a = stack.pop();
                try stack.append(@divFloor(a, b));
                ip += 1;
            },
            .MODULUSI => {
                const b = stack.pop();
                const a = stack.pop();
                try stack.append(@mod(a, b));
                ip += 1;
            },

            .JMP => {
                // std.log.debug("{d} JMP {d}", .{ ip, readInt(bytecode, ip + 1) });
                ip = @intCast(readInt(bytecode, ip + 1));
            },
            .JMP_EQ_ZERO => {
                const v = stack.pop();
                // std.log.debug("{d} JMP_EQ_ZERO {d} ({d})", .{ ip, readInt(bytecode, ip + 1), v });
                if (v == 0) {
                    ip = @intCast(readInt(bytecode, ip + 1));
                } else {
                    ip += 5;
                }
            },
            .JMP_NEQ_ZERO => {
                const v = stack.pop();
                if (v != 0) {
                    ip = @intCast(readInt(bytecode, ip + 1));
                } else {
                    ip += 5;
                }
            },

            // else => {
            //     try stdout.print("Unknown opcode: {} at {d}\n", .{ bytecode[ip], ip });
            //     unreachable;
            // },
        }
    }
    if (stack.items.len > 0) {
        return stack.pop();
    } else {
        return 0;
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
