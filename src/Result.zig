const std = @import("std");

const Allocator = std.mem.Allocator;
const result_property = @import("ResultProperty.zig");

pub const ResultProperty = result_property.ResultProperty;

pub const ResultVTable = struct {
    resultProperties: *const fn (*anyopaque) Result.ResultError![]const ResultProperty,
};

pub const Result = struct {
    pub const ResultError = anyerror;

    ptr: *anyopaque,
    vtable: *const ResultVTable,

    pub fn resultProperties(self: Result) ResultError![]const ResultProperty {
        return self.vtable.resultProperties(self.ptr);
    }

    pub fn resultObject(self: *const Result) ResultObject {
        return .{
            .ptr = @constCast(self),
            .vtable = &legacy_result_object_vtable,
        };
    }
};

pub const ResultObjectError = Result.ResultError || std.mem.Allocator.Error;

pub const ResultObject = struct {
    ptr: *const anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        resultProperties: *const fn (*const anyopaque, Allocator) ResultObjectError![]ResultProperty,
    };

    pub fn resultProperties(self: ResultObject, allocator: Allocator) ResultObjectError![]ResultProperty {
        return self.vtable.resultProperties(self.ptr, allocator);
    }
};

const legacy_result_object_vtable = ResultObject.VTable{
    .resultProperties = legacyResultProperties,
};

fn legacyResultProperties(ctx: *const anyopaque, allocator: Allocator) ResultObjectError![]ResultProperty {
    const self: *const Result = @ptrCast(@alignCast(ctx));
    const props = try self.vtable.resultProperties(self.ptr);
    const copy = try allocator.alloc(ResultProperty, props.len);
    for (props, 0..) |prop, idx| {
        copy[idx] = prop;
    }
    return copy;
}
