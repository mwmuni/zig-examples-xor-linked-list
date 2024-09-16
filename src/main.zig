const std = @import("std");
const linked_list = @import("linked-list.zig");

pub fn main() !void {
    var list = try linked_list.make_random_linked_list(u32, 10, linked_list.RandomGenerator_u32);
    defer linked_list.deinit(u32, &list);

    linked_list.print(u32, &list); // Pass the list to the print function
    linked_list.reverse(u32, &list);
    linked_list.print(u32, &list);
}
