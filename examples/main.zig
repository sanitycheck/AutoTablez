const std = @import("std");
const at = @import("AutoTablez");
const Person = @import("Person.zig").Person;
const AutoTable = at.AutoTable;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var people = [_]Person{
        Person.init(allocator, "Alice", 30, 1.68),
        Person.init(allocator, "Bob", 25, 1.82),
        Person.init(allocator, "Charlie", 35, 1.75),
    };

    var table = try AutoTable(Person).init(allocator, people[0..]);
    defer table.deinit();

    const output = try table.toString();
    std.debug.print("\n{s}\n", .{output});
}
