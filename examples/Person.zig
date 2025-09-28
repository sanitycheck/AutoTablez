const std = @import("std");
const at = @import("AutoTablez");

const Allocator = std.mem.Allocator;
const Result = at.Result;
const ResultProperty = at.ResultProperty;

pub const Person = struct {
    name: []const u8,
    age: u32,
    height: f32,
    allocator: Allocator,

    pub fn init(allocator: Allocator, name: []const u8, age: u32, height: f32) Person {
        return .{
            .name = name,
            .age = age,
            .height = height,
            .allocator = allocator,
        };
    }

    pub fn resultObject(self: *const Person) Result {
        return .{
            .ptr = @constCast(self),
            .vtable = &.{
                .resultProperties = resultProperties,
            },
        };
    }
};

fn resultProperties(ctx: *anyopaque) anyerror![]const ResultProperty {
    const self: *Person = @ptrCast(@alignCast(ctx));

    const props = try self.allocator.alloc(ResultProperty, 3);
    props[0] = .{ .name = "Name", .value = self.name };
    props[1] = .{ .name = "Age", .value = try std.fmt.allocPrint(self.allocator, "{}", .{self.age}) };
    props[2] = .{ .name = "Height", .value = try std.fmt.allocPrint(self.allocator, "{d:.2}", .{self.height}) };

    return props;
}
