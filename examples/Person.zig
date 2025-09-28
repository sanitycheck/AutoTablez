const std = @import("std");
const at = @import("AutoTablez");

const Allocator = std.mem.Allocator;
const ResultProperty = at.ResultProperty;
const ResultObject = at.ResultObject;

pub const Person = struct {
    name: []const u8,
    age: u32,
    height: f32,

    pub fn resultObject(self: *const Person) ResultObject {
        return .{
            .ptr = self,
            .vtable = &.{
                .resultProperties = resultProperties,
            },
        };
    }
};

fn resultProperties(ctx: *const anyopaque, allocator: Allocator) ![]ResultProperty {
    const self: *const Person = @ptrCast(@alignCast(ctx));

    const age_value = try std.fmt.allocPrint(allocator, "{}", .{self.age});
    errdefer allocator.free(age_value);

    const height_value = try std.fmt.allocPrint(allocator, "{d:.2}", .{self.height});
    errdefer allocator.free(height_value);

    const props = try allocator.alloc(ResultProperty, 3);
    props[0] = .{ .name = "Name", .value = self.name };
    props[1] = .{ .name = "Age", .value = age_value, .owns_value = true };
    props[2] = .{ .name = "Height", .value = height_value, .owns_value = true };

    return props;
}
