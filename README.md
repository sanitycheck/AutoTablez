# AutoTablez 📋  
*A Simple, Type-Safe Table Formatting Library for Zig*

Format structs into clean, aligned text tables with minimal effort using a dynamic dispatch interface. Ideal for CLI tools, debug output, or presenting structured data.

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
- **Customizable** – Full control over value rendering  
- **Zero Allocations** (optional) – Use fixed buffers for embedded systems  

## Installation 📦  
Run the following fetch command
```
zig fetch --save git+https://github.com/sanitycheck/AutoTablez
```
Or manually add the Zig module in your `build.zig.zon`:  
```zig
.dependencies = .{
    .AutoTablez = .{
        .url = "https://github.com/sanitycheck/AutoTablez/archive/refs/heads/main.tar.gz",
        .hash = "..." // Add hash after first fetch
    },
},
```
then update your build.zig to add AutoTablez dependency to the root_module.
```zig
    const at_dep = b.dependency("AutoTablez", .{
        .target = target,
        .optimize = optimize,
    });
    ...

    exe.root_module.addImport("AutoTablez", at_dep.module("AutoTablez"));
```
## Usage 🚀  
### 1. Import the Module
```zig
const AutoTablez = @import("AutoTablez");
const Result = AutoTablez.Result;
const ResultProperty = AutoTablez.ResultProperty;
const ResultError = Result.ResultError;
```
### 2. Define Your Struct  
```zig
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

```

### 3. Create a Result List  
```zig
...
    var userList = try AutoTablez.init(allocator);
    defer userList.deinit();

    var user1 = User.init(allocator, "Alice", 30, "Active");
    var user2 = User.init(allocator, "Bob", 25, "Inactive");
    var user3 = User.init(allocator, "Charlie", 35, "Active");
    
    try userList.append(try user1.toResult());
    try userList.append(try user2.toResult());
    try userList.append(try user3.toResult());

    const table = try userList.toString();
    defer allocator.free(table);
    std.debug.print("User List:\n\n{s}\n\n", .{table});
```

### 4. Print the Table  
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