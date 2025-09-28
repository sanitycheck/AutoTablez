const std = @import("std");
const at = @import("AutoTablez");
const Person = @import("Person.zig").Person;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const people = [_]Person{
        .{ .name = "Alice", .age = 30, .height = 1.68 },
        .{ .name = "Bob", .age = 25, .height = 1.82 },
        .{ .name = "Charlie", .age = 35, .height = 1.75 },
    };

    var table = try at.AutoTable(Person).init(allocator, people[0..]);
    defer table.deinit();

    const output = try table.toString();
    std.debug.print("\n{s}\n", .{output});
}
