`timescale 1ns/1ps
`include "fifo.v"

module fifo_tb();

// Parameters
parameter fifo_width = 8;
parameter fifo_depth = 8;
parameter address_size = $clog2(fifo_depth) + 1;

// Signals
reg write_clk_tb, read_clk_tb, rst_tb, write_en_tb, read_en_tb;
reg [fifo_width-1:0] write_data_tb;
wire [fifo_width-1:0] read_data_tb;
wire empty_tb, full_tb;

// Declare loop variables outside the initial block
integer i, j;

// Instantiate the FIFO module
fifo #(fifo_width, fifo_depth) uut (
    .write_clk(write_clk_tb),
    .read_clk(read_clk_tb),
    .rst(rst_tb),
    .write_en(write_en_tb),
    .read_en(read_en_tb),
    .write_data(write_data_tb),
    .read_data(read_data_tb),
    .empty(empty_tb),
    .full(full_tb)
);

// Clock generation
always #5 write_clk_tb = ~write_clk_tb;  // 100 MHz write clock
always #7 read_clk_tb = ~read_clk_tb;    // ~71 MHz read clock

// Test sequence
initial begin
    // Initialize signals
    write_clk_tb = 0;
    read_clk_tb = 0;
    rst_tb = 0;
    write_en_tb = 0;
    read_en_tb = 0;
    write_data_tb = 0;

    // Apply reset
    rst_tb = 1;
    #15;
    rst_tb = 0;

    // Writing to FIFO
    $display("Starting write operations...");
    write_en_tb = 1;
    for (i = 0; i < fifo_depth; i = i + 1) begin
        write_data_tb = i;
        #10;  // Wait for one write clock cycle
    end
    write_en_tb = 0;
    $display("Finished writing to FIFO.");

    // Attempt to write when full
    #20;
    $display("Attempting to write to full FIFO...");
    write_en_tb = 1;
    write_data_tb = 8'hFF;
    if (full_tb) begin
        $display("FIFO is full. Cannot write more data.");
    end
    #10;
    write_en_tb = 0;

    // Reading from FIFO
    $display("Starting read operations...");
    read_en_tb = 1;
    for (j = 0; j < fifo_depth; j = j + 1) begin
        #14;  // Wait for one read clock cycle
        $display("Read data from FIFO: %h", read_data_tb);  // Display the read data on the console
    end
    read_en_tb = 0;
    $display("Finished reading from FIFO.");

    // Attempt to read when empty
    #20;
    $display("Attempting to read from empty FIFO...");
    read_en_tb = 1;
    if (empty_tb) begin
        $display("FIFO is empty. No data to read.");
    end
    #14;
    $display("Read data from FIFO (empty state): %h", read_data_tb);
    read_en_tb = 0;

    // Final check for empty and full flags
    $display("Checking empty and full conditions...");
    #20;
    if (empty_tb)
        $display("FIFO is empty.");
    else
        $display("FIFO is not empty.");

    if (full_tb)
        $display("FIFO is full.");
    else
        $display("FIFO is not full.");

    $finish;
end

endmodule
