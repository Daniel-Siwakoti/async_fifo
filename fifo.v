module fifo (write_clk, read_clk, rst, write_en, read_en, write_data, read_data, valid, empty, full);

parameter fifo_width = 8;
parameter fifo_depth = 8;
parameter address_size = $clog2(fifo_depth) + 1;

input write_clk, read_clk, rst, write_en, read_en;
input [fifo_width-1:0] write_data;
output reg [fifo_width-1:0] read_data;
output valid, empty, full;

wire [address_size-1:0] write_pointer_gray;
wire [address_size-1:0] read_pointer_gray;

reg [address_size-1:0] write_pointer;
reg [address_size-1:0] read_pointer;

reg [address_size-1:0] Q0_readdomain, Q1_readdomain;
reg [address_size-1:0] Q0_writedomain, Q1_writedomain;

reg [fifo_width-1:0] memory[fifo_depth-1:0];

always @(posedge write_clk) begin
    if (rst) begin
        write_pointer <= 0;
    end else begin
        if (write_en && !full) begin
            memory[write_pointer] <= write_data;
            write_pointer <= write_pointer + 1;
        end
    end
end

always @(posedge read_clk) begin
    if (rst) begin
        read_pointer <= 0;
    end else begin
        if (read_en && !empty) begin
            read_data = memory[read_pointer];
            read_pointer <= read_pointer + 1;
        end
    end
end

assign write_pointer_gray = write_pointer ^ (write_pointer >> 1);
assign read_pointer_gray = read_pointer ^ (read_pointer >> 1);

always @(posedge read_clk) begin
    if (rst) begin
        Q0_readdomain <= 0;
        Q1_readdomain <= 0;
    end else begin
        Q0_readdomain <= write_pointer_gray;
        Q1_readdomain <= Q0_readdomain;
    end
end

always @(posedge write_clk) begin
    if (rst) begin
        Q0_writedomain <= 0;
        Q1_writedomain <= 0;
    end else begin
        Q0_writedomain <= read_pointer_gray;
        Q1_writedomain <= Q0_writedomain;
    end
end

assign empty = (read_pointer_gray == Q1_readdomain);
assign full = (write_pointer_gray == {~Q1_writedomain[address_size-1:address_size-2], Q1_writedomain[address_size-3:0]});

endmodule
