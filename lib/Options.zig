const std = @import("std");
const c = @import("root.zig").c;

const Heif = struct {
    /// First page to load, input gint
    /// default: 0
    /// min: 0, max: 100000
    page: ?u10 = null,
    /// Number of pages to load, -1 for all, input gint
    /// default: 1
    /// min: -1, max: 100000
    n: ?i11 = null,
    /// Fetch thumbnail image, input gboolean
    /// default: false
    thumbnail: ?bool = null,
    /// Remove all denial of service limits, input gboolean
    unlimited: ?bool = null,
    /// TODO: this can't be passed with the [key=value] format
    /// as it is an out param
    /// get Flags for this file, output VipsForeignFlags
    flags: ?*c.vips.ForeignFlags = null,
    /// Force open via memory, input gboolean
    /// default: false
    memory: ?bool = null,
    /// Required access pattern for this file, input VipsAccess
    /// default enum: random
    access: ?c.vips.Access = null,
    /// Error level to fail on, input VipsFailOn
    /// default enum: none
    @"fail-on": ?c.vips.FailOn = null,
    /// Don't use a cached result for this operation, input gboolean
    /// default: false
    revalidate: ?bool = null,
};

// TODO: add general load and save options and loader specific options
pub const Image = struct {
    pub const Load = union(enum) {
        all: struct {},
        heif: Heif,

        /// caller owns memory and must free with `allocator.free` when done
        pub fn toString(self: Load, allocator: std.mem.Allocator) []const u8 {
            const char_count = 128; //random number bump if limit is hit
            var options = std.ArrayList(u8).initCapacity(allocator, char_count) catch unreachable;
            options.appendAssumeCapacity('[');

            var writer = options.writer();

            switch (self) {
                .heif => |heif_options| {
                    if (heif_options.page) |page| {
                        writer.print("page={}", .{page}) catch unreachable;
                        writer.writeByte(',') catch unreachable;
                    } else if (heif_options.n) |n| {
                        writer.print("n={}", .{n}) catch unreachable;
                        writer.writeByte(',') catch unreachable;
                    } else if (heif_options.thumbnail) |thumbnail| {
                        writer.print("thumbnail={}", .{thumbnail}) catch unreachable;
                        writer.writeByte(',') catch unreachable;
                    } else if (heif_options.unlimited) |unlimited| {
                        writer.print("unlimited={}", .{unlimited}) catch unreachable;
                        writer.writeByte(',') catch unreachable;
                    } else if (heif_options.memory) |memory| {
                        writer.print("memory={}", .{memory}) catch unreachable;
                        writer.writeByte(',') catch unreachable;
                    } else if (heif_options.access) |access| {
                        writer.print("access={s}", .{@tagName(access)}) catch unreachable;
                        writer.writeByte(',') catch unreachable;
                    } else if (heif_options.@"fail-on") |fail_on| {
                        writer.print("fail-on={s}", .{@tagName(fail_on)}) catch unreachable;
                        writer.writeByte(',') catch unreachable;
                    } else if (heif_options.revalidate) |revalidate| {
                        writer.print("revalidate={}", .{revalidate}) catch unreachable;
                        writer.writeByte(',') catch unreachable;
                    }
                },
                .all => {},
            }

            // replace last ',' with ']'
            options.replaceRangeAssumeCapacity(options.items.len - 1, 1, "]");

            return options.toOwnedSlice() catch unreachable;
        }
    };
    pub const Save = union(enum) {};
};
