# AutoTablez 📋  
*A Simple, Type-Safe Table Formatting Library for Zig*

Format structs into clean, aligned text tables with minimal effort. Perfect for CLI tools, debugging outputs, or organizing data.

```zig
const users = &.{ user1, user2, user3 };
const userList = try AutoTable(User).init(allocator, users);
defer userList.deinit();
const table = try userList.toString();
std.debug.print("{s}\n", .{table});
```

**Example Output:**  
```
Name      Age  Status  
------    ---  ------  
Alice     28   active  
Bob       32   inactive  
Charlie   25   pending
```

## Features ✨  
- **Automatic Column Sizing** – Columns expand to fit content  
- **Header Generation** – Infers column names from struct properties  
- **Type-Safe** – Built for Zig's compile-time type system  
- **Customizable** – Extend via `resultProperties` method  
- **Zero Allocations** (optional) – Use fixed buffers for embedded systems  

## Installation 📦  
Add as a Zig module in your `build.zig.zon`:  
```zig
.dependencies = .{
    .AutoTablez = .{
        .url = "https://github.com/sanitycheck/AutoTablez/archive/refs/heads/main.tar.gz",
        .hash = "..." // Add hash after first fetch
    },
},
```

## Usage 🚀  

### 1. Define Your Struct  
```zig
const User = struct {
    name: []const u8,
    age: u8,
    status: []const u8,

    pub fn resultProperties(self: @This(), allocator: Allocator) ![]const ResultProperty {
        return &.{
            .{ .name = "Name", .value = self.name },
            .{ .name = "Age", .value = try std.fmt.allocPrint(allocator, "{d}", .{self.age}) },
            .{ .name = "Status", .value = self.status },
        };
    }
};
```

### 2. Create a Result List  
```zig
const users = &.{
    User{ .name = "Alice", .age = 28, .status = "active" },
    User{ .name = "Bob", .age = 32, .status = "inactive" },
};
var userList = try AutoTable(User).init(allocator, users);
defer userList.deinit();
```

### 3. Print the Table  
```zig
const table = try userList.toString();
std.debug.print("\n{s}\n", .{table});
```

## Advanced Options ⚙️  

### Custom Headers  
Override property names in `resultProperties`:  
```zig
.{ .name = "👑 User", .value = self.name } // Custom header
```

### Formatting Non-String Values  
Use `std.fmt` for complex types:  
```zig
.{ 
    .name = "Score", 
    .value = try std.fmt.allocPrint(allocator, "{d:.2}", .{self.score}) 
}
```

## Contributing 🤝  
PRs welcome!

## License 📄  
MIT License - See [LICENSE](LICENSE) for details.