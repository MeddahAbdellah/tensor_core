`timescale 1ns/1ps

module char_incr_tb;

  // Parameters
  localparam ADDR_WIDTH = 4;
  
  // Signals
  logic clk;
  logic rst_n;
  logic [ADDR_WIDTH-1:0] start_addr;
  logic [ADDR_WIDTH-1:0] end_addr;
  logic [ADDR_WIDTH-1:0] curr_addr;
  logic overflow;

  // Instantiate the Unit Under Test (UUT)
  char_incr #(
    .ADDR_WIDTH(ADDR_WIDTH)
  ) uut (
    .clk(clk),
    .rst_n(rst_n),
    .start_addr(start_addr),
    .end_addr(end_addr),
    .curr_addr(curr_addr),
    .overflow(overflow)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test stimulus
  initial begin
    // Initialize inputs
    clk = 0;
    rst_n = 1;
    start_addr = 4'b0000;
    end_addr = 4'b1111;

    // Apply reset
    #10 rst_n = 0;
    #10 rst_n = 1;
    #200;
    // End simulation
    #10 $finish;
  end

  // Monitor
  always @(posedge clk) begin
    $display("Time=%0t: rst_n=%b, start_addr=%h, end_addr=%h, curr_addr=%h, overflow=%b", 
             $time, rst_n, start_addr, end_addr, curr_addr, overflow);
  end

endmodule