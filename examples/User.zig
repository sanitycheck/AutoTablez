const User = @This();

name: []const u8,
age: u8,
status: []const u8,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator, name: []const u8, age: u8, status: []const u8) User {
    return User{
        .name = name,
        .age = age,
        .status = status,
        .allocator = allocator,
    };
}

fn resultProperties(ctx: *anyopaque) ResultError![]ResultProperty {
    const self: *User = @ptrCast(@alignCast(ctx));
    const properties = self.allocator.alloc(ResultProperty, 3) catch return ResultError.GetResultPropertiesFailed;
    properties[0] = ResultProperty{ .name = "Name", .value = self.name };
    properties[1] = ResultProperty{ .name = "Age", .value = std.fmt.allocPrint(self.allocator, "{d}", .{self.age}) catch return ResultError.GetResultPropertiesFailed };
    properties[2] = ResultProperty{ .name = "Status", .value = self.status };
    return properties;
}

pub fn toResult(self: *User) !Result {
    return Result{
        .ptr = @ptrCast(self),
        .vtable = &.{
            .resultProperties = resultProperties,
        },
    };
}

// Imports //
const std = @import("std");
const AutoTablez = @import("AutoTablez");
const Result = AutoTablez.Result;
const ResultProperty = AutoTablez.ResultProperty;
const ResultError = Result.ResultError;