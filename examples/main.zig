
pub fn main() !void {
    var userList = try AutoTablez.init(std.heap.page_allocator);
    defer userList.deinit();

    var user1 = User.init(std.heap.page_allocator, "Alice", 30, "Active");
    var user2 = User.init(std.heap.page_allocator, "Bob", 25, "Inactive");
    var user3 = User.init(std.heap.page_allocator, "Charlie", 35, "Active");
    try userList.append(try user1.toResult());
    try userList.append(try user2.toResult());
    try userList.append(try user3.toResult());

    const table = try userList.toString();
    std.debug.print("\nUser List:\n\n{s}\n\n", .{table});
    std.heap.page_allocator.free(table);
    std.debug.print("User List printed successfully.\n", .{});
}
const std = @import("std");
const User = @import("User.zig");
const AutoTablez = @import("AutoTablez");