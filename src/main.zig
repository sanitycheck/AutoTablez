const std = @import("std");
const go = @import("GenericObject.zig");
const GenericObjectResult = go.GenericObjectResult;
const GenericResultList = go.AutoTable;
const GenericResultProperty = go.ResultProperty;
const Allocator = std.mem.Allocator;

pub const Person = struct {
    name: []const u8,
    age: u32,
    height: f32,

    pub fn resultProperties(self: *const @This(), allocator: Allocator) ![]const GenericResultProperty {
        const properties = try allocator.alloc(GenericResultProperty, 3);

        properties[0] = .{
            .name = "Name",
            .value = try std.fmt.allocPrint(allocator, "{s}", .{self.name}),
        };

        properties[1] = .{
            .name = "Age",
            .value = try std.fmt.allocPrint(allocator, "{}", .{self.age}),
        };

        properties[2] = .{
            .name = "Height",
            .value = try std.fmt.allocPrint(allocator, "{d:.2}", .{self.height}),
        };

        return properties;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Create some people
    const people = &.{
        Person{ .name = "Alice", .age = 30, .height = 1.68 },
        Person{ .name = "Bob", .age = 25, .height = 1.82 },
        Person{ .name = "Charlie", .age = 35, .height = 1.75 },
    };

    // Create and populate result list
    var result_list = try GenericResultList(Person).init(allocator, people);
    defer result_list.deinit();

    // Format and print
    const output = try result_list.toString();
    std.debug.print("\n{s}\n", .{output});
}
