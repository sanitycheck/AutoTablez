const Result = @This();

ptr: *anyopaque,
vtable: *const ResultVTable,

pub const ResultVTable = struct {
    resultProperties: *const fn (self: *anyopaque) ResultError![]ResultProperty,
};

pub fn resultProperties(self: *const Result) ResultError![]ResultProperty {
    return self.vtable.resultProperties(self.ptr);
}

pub const ResultProperty = struct {
    name: []const u8,
    value: []const u8,
};

pub const ResultError = error{
    GetResultPropertiesFailed,
};