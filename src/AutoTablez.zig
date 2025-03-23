const std = @import("std");
const Allocator = std.mem.Allocator;

pub const ResultProperty = struct {
    name: []const u8,
    value: []const u8,
};

pub fn AutoTable(comptime T: type) type {
    return struct {
        resultList: std.ArrayList(T),
        allocator: Allocator,

        const Self = @This();

        pub fn init(allocator: Allocator, input: []const T) !Self {
            var list = std.ArrayList(T).init(allocator);
            try list.appendSlice(input);
            return Self{
                .resultList = list,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.resultList.deinit();
        }

        pub fn addRange(self: *Self, range: []const T) !void {
            try self.resultList.appendSlice(range);
        }

        pub fn toString(self: *const Self) ![]const u8 {
            if (self.resultList.items.len == 0) {
                return "";
            }

            const first_element = self.resultList.items[0];
            const first_properties = try first_element.resultProperties(self.allocator);
            const num_columns = first_properties.len;

            var max_column_widths = try self.allocator.alloc(usize, num_columns);

            // Initialize with header name lengths
            for (first_properties, 0..) |prop, i| {
                max_column_widths[i] = prop.name.len;
            }

            // Update with maximum value lengths
            for (self.resultList.items) |element| {
                const props = try element.resultProperties(self.allocator);
                for (props, 0..) |prop, i| {
                    max_column_widths[i] = @max(max_column_widths[i], prop.value.len);
                }
            }

            var buffer = std.ArrayList(u8).init(self.allocator);
            defer buffer.deinit();
            const writer = buffer.writer();

            // Write headers (fixed)
            for (first_properties, 0..) |prop, i| {
                try writer.writeAll(prop.name);
                const remaining = max_column_widths[i] - prop.name.len;
                if (remaining > 0) {
                    try writer.writeByteNTimes(' ', remaining);
                }
                if (i != num_columns - 1) {
                    try writer.writeAll("  ");
                }
            }
            try writer.writeByte('\n');

            // Write underline
            for (first_properties, 0..) |prop, i| {
                const underline_len = prop.name.len;
                const underline = try self.allocator.alloc(u8, underline_len);
                @memset(underline, '-');
                try writer.writeAll(underline);
                const remaining = max_column_widths[i] - underline_len;
                if (remaining > 0) {
                    try writer.writeByteNTimes(' ', remaining);
                }
                if (i != num_columns - 1) {
                    try writer.writeAll("  ");
                }
            }
            try writer.writeByte('\n');

            // Write rows
            for (self.resultList.items) |element| {
                const props = try element.resultProperties(self.allocator);
                for (props, 0..) |prop, i| {
                    try writer.writeAll(prop.value);
                    const remaining = max_column_widths[i] - prop.value.len;
                    if (remaining > 0) {
                        try writer.writeByteNTimes(' ', remaining);
                    }
                    if (i != num_columns - 1) {
                        try writer.writeAll("  ");
                    }
                }
                try writer.writeByte('\n');
            }

            return buffer.toOwnedSlice();
        }
    };
}
