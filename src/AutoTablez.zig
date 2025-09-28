const std = @import("std");

const Allocator = std.mem.Allocator;
const result_property = @import("ResultProperty.zig");
const result_object = @import("Result.zig");

pub const ResultProperty = result_property.ResultProperty;
pub const ResultObject = result_object.ResultObject;

pub fn AutoTable(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: Allocator,
        rows: std.ArrayList(ResultObject),

        pub fn init(allocator: Allocator, items: []const T) !Self {
            var rows = std.ArrayList(ResultObject).empty;
            errdefer rows.deinit(allocator);

            if (items.len != 0) {
                try rows.ensureTotalCapacityPrecise(allocator, items.len);
            }
            for (items) |*item| {
                try rows.append(allocator, item.resultObject());
            }

            return .{
                .allocator = allocator,
                .rows = rows,
            };
        }

        pub fn deinit(self: *Self) void {
            self.rows.deinit(self.allocator);
        }

        pub fn append(self: *Self, item: *const T) !void {
            try self.rows.append(self.allocator, item.resultObject());
        }

        pub fn appendSlice(self: *Self, items: []const T) !void {
            if (items.len == 0) return;
            try self.rows.ensureTotalCapacity(self.allocator, self.rows.items.len + items.len);
            for (items) |*item| {
                try self.rows.append(self.allocator, item.resultObject());
            }
        }

        pub fn toString(self: *Self) ![]const u8 {
            if (self.rows.items.len == 0) {
                return "";
            }

            const row_count = self.rows.items.len;

            var row_props = try self.allocator.alloc([]ResultProperty, row_count);
            var filled_rows: usize = 0;
            var max_widths: []usize = undefined;
            var has_widths = false;
            var column_count: usize = 0;

            defer {
                if (has_widths) {
                    self.allocator.free(max_widths);
                }
                var idx: usize = 0;
                while (idx < filled_rows) : (idx += 1) {
                    result_property.destroySlice(self.allocator, row_props[idx]);
                }
                self.allocator.free(row_props);
            }

            for (self.rows.items) |row| {
                const props = try row.resultProperties(self.allocator);
                row_props[filled_rows] = props;
                filled_rows += 1;

                if (!has_widths) {
                    column_count = props.len;
                    if (column_count == 0) {
                        return "";
                    }
                    max_widths = try self.allocator.alloc(usize, column_count);
                    has_widths = true;
                    for (props, 0..) |prop, col_idx| {
                        var width = prop.name.len;
                        width = @max(width, prop.value.len);
                        max_widths[col_idx] = width;
                    }
                } else {
                    if (props.len != column_count) {
                        return error.MismatchedColumnCount;
                    }
                    for (props, 0..) |prop, col_idx| {
                        max_widths[col_idx] = @max(max_widths[col_idx], prop.name.len);
                        max_widths[col_idx] = @max(max_widths[col_idx], prop.value.len);
                    }
                }
            }

            var buffer = std.ArrayList(u8).empty;
            defer buffer.deinit(self.allocator);
            const writer = buffer.writer(self.allocator);

            const headers = row_props[0];

            for (headers, 0..) |prop, col_idx| {
                try writer.writeAll(prop.name);
                const padding = max_widths[col_idx] - prop.name.len;
                if (padding > 0) {
                    try writer.writeByteNTimes(' ', padding);
                }
                if (col_idx + 1 < column_count) {
                    try writer.writeAll("  ");
                }
            }
            try writer.writeByte('\n');

            for (headers, 0..) |prop, col_idx| {
                const header_width = prop.name.len;
                try writer.writeByteNTimes('-', header_width);
                const padding = max_widths[col_idx] - header_width;
                if (padding > 0) {
                    try writer.writeByteNTimes(' ', padding);
                }
                if (col_idx + 1 < column_count) {
                    try writer.writeAll("  ");
                }
            }
            try writer.writeByte('\n');

            for (row_props) |props| {
                for (props, 0..) |prop, col_idx| {
                    try writer.writeAll(prop.value);
                    const padding = max_widths[col_idx] - prop.value.len;
                    if (padding > 0) {
                        try writer.writeByteNTimes(' ', padding);
                    }
                    if (col_idx + 1 < column_count) {
                        try writer.writeAll("  ");
                    }
                }
                try writer.writeByte('\n');
            }

            return buffer.toOwnedSlice(self.allocator);
        }
    };
}
