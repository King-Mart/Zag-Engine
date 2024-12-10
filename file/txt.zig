const textFile = struct {
    name: []const u8,
    data: []const u8,
    fn read(self: textFile) void {self;}
    fn write(self: textFile) void {self;}

};