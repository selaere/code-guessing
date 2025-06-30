const std = @import("std");

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = general_purpose_allocator.allocator();
    const args = try std.process.argsAlloc(gpa);
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d}\n", .{args[1].len});
}