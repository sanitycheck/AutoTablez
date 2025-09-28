const std = @import("std");

const Allocator = std.mem.Allocator;

pub const ResultProperty = struct {
    name: []const u8,
    value: []const u8,
    owns_value: bool = false,

    pub fn deinit(self: *ResultProperty, allocator: Allocator) void {
        if (self.owns_value) {
            allocator.free(@constCast(self.value));
        }
    }
};

pub fn destroySlice(allocator: Allocator, props: []ResultProperty) void {
    for (props) |*prop| {
        prop.deinit(allocator);
    }
    allocator.free(props);
}
