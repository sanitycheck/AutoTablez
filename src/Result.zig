const std = @import("std");

const Allocator = std.mem.Allocator;
const result_property = @import("ResultProperty.zig");

pub const ResultObject = struct {
    ptr: *const anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        resultProperties: *const fn (*const anyopaque, Allocator) anyerror![]result_property.ResultProperty,
    };

    pub fn resultProperties(self: ResultObject, allocator: Allocator) ![]result_property.ResultProperty {
        return self.vtable.resultProperties(self.ptr, allocator);
    }
};
