const std = @import("std");
const allocator = std.heap.page_allocator;

var seed: u32 = 0;

fn Node(comptime T: type) type {
    return struct {
        value: T,
        npx: usize, // XOR of next and prev node pointers
    };
}

fn LinkedList(comptime T: type) type {
    return struct {
        head: ?*Node(T),
        tail: ?*Node(T),
    };
}

pub fn make_linked_list(comptime T: type) type {
    return LinkedList(T);
}

// Random number generator
pub fn RandomGenerator_u32() u32 {
    seed = seed *% 1664525 +% 1013904223; // Wrapping multiplication and addition
    return seed % 100; // Limit to 0-99
}

pub fn make_random_linked_list(comptime T: type, comptime N: usize, comptime RandomGenerator: fn () T) !LinkedList(T) {
    var list = LinkedList(T){ .head = null, .tail = null };
    var prev_ptr: usize = 0;

    for (0..N) |_| {
        const new_node = try allocator.create(Node(T));
        new_node.* = Node(T){ .value = RandomGenerator(), .npx = prev_ptr };

        if (list.tail) |tail| {
            // Update the previous node's npx to include the new node
            tail.npx ^= @intFromPtr(new_node);
        } else {
            list.head = new_node;
        }
        prev_ptr = @intFromPtr(new_node);
        list.tail = new_node;
    }

    return list;
}

pub fn deinit(comptime T: type, self: *const LinkedList(T)) void {
    var current = self.head;
    var prev_ptr: usize = 0;

    while (current) |node| {
        const next_ptr = prev_ptr ^ node.npx;
        prev_ptr = @intFromPtr(node);
        allocator.destroy(node);
        current = @ptrFromInt(next_ptr);
    }
}

pub fn print(comptime T: type, self: *const LinkedList(T)) void {
    var current = self.head;
    var prev_ptr: usize = 0;

    while (current) |node| {
        std.debug.print("{} ", .{node.value});
        const next_ptr = prev_ptr ^ node.npx;
        prev_ptr = @intFromPtr(current);
        current = @ptrFromInt(next_ptr);
    }
    std.debug.print("\n", .{});
}

pub fn reverse(comptime T: type, self: *LinkedList(T)) void {
    // Swap head and tail
    const temp = self.head;
    self.head = self.tail;
    self.tail = temp;
}
