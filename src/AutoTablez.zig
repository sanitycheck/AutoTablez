const std = @import("std");

const Allocator = std.mem.Allocator;
const ResultModule = @import("Result.zig");

pub const ResultProperty = ResultModule.ResultProperty;
pub const ResultVTable = ResultModule.ResultVTable;
pub const Result = ResultModule.Result;
pub const ResultObject = ResultModule.ResultObject;

pub const AutoTablez = struct {
    allocator: Allocator,
    rows: std.ArrayList(Result),

    pub fn init(allocator: Allocator) !AutoTablez {
        return .{
            .allocator = allocator,
            .rows = std.ArrayList(Result).empty,
        };
    }

    pub fn deinit(self: *AutoTablez) void {
        self.rows.deinit(self.allocator);
    }

    pub fn addRange(self: *AutoTablez, range: []const Result) !void {
        if (range.len == 0) return;
        try self.rows.ensureTotalCapacity(self.allocator, self.rows.items.len + range.len);
        try self.rows.appendSlice(self.allocator, range);
    }

    pub fn append(self: *AutoTablez, item: Result) !void {
        try self.rows.append(self.allocator, item);
    }

    pub fn toString(self: *AutoTablez) ![]const u8 {
        return formatResults(self.allocator, self.rows.items);
    }
};

pub fn AutoTable(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: Allocator,
        rows: std.ArrayList(Result),

        pub fn init(allocator: Allocator, items: []const T) !Self {
            var rows = std.ArrayList(Result).empty;
            errdefer rows.deinit(allocator);

            if (items.len != 0) {
                try rows.ensureTotalCapacity(allocator, items.len);
                for (items) |*item| {
                    try rows.append(allocator, item.resultObject());
                }
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
            return formatResults(self.allocator, self.rows.items);
        }
    };
}

fn formatResults(allocator: Allocator, rows: []const Result) ![]const u8 {
    if (rows.len == 0) {
        return "";
    }

    const first = rows[0];
    const first_properties = try first.resultProperties();
    if (first_properties.len == 0) {
        return "";
    }

    const column_count = first_properties.len;
    var max_widths = try allocator.alloc(usize, column_count);
    defer allocator.free(max_widths);

    for (first_properties, 0..) |prop, idx| {
        max_widths[idx] = prop.name.len;
    }

    for (rows) |result| {
        const props = try result.resultProperties();
        for (props, 0..) |prop, idx| {
            max_widths[idx] = @max(max_widths[idx], prop.value.len);
        }
    }

    var buffer = std.ArrayList(u8).empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);

    for (first_properties, 0..) |prop, idx| {
        try writer.writeAll(prop.name);
        const padding = max_widths[idx] - prop.name.len;
        if (padding > 0) {
            try writer.writeByteNTimes(' ', padding);
        }
        if (idx + 1 < column_count) {
            try writer.writeAll("  ");
        }
    }
    try writer.writeByte('\n');

    for (first_properties, 0..) |prop, idx| {
        try writer.writeByteNTimes('-', prop.name.len);
        const padding = max_widths[idx] - prop.name.len;
        if (padding > 0) {
            try writer.writeByteNTimes(' ', padding);
        }
        if (idx + 1 < column_count) {
            try writer.writeAll("  ");
        }
    }
    try writer.writeByte('\n');

    for (rows) |result| {
        const props = try result.resultProperties();
        for (props, 0..) |prop, idx| {
            try writer.writeAll(prop.value);
            const padding = max_widths[idx] - prop.value.len;
            if (padding > 0) {
                try writer.writeByteNTimes(' ', padding);
            }
            if (idx + 1 < column_count) {
                try writer.writeAll("  ");
            }
        }
        try writer.writeByte('\n');
    }

    return buffer.toOwnedSlice(allocator);
}
