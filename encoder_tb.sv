`timescale 1ns/1ps

module encoder_tb;

  // Parameters
  parameter ADDR_WIDTH = 4;
  parameter DATA_WIDTH = 8;

  // Signals
  logic clk;
  logic rst_n;
  logic cs;

  // Instantiate the Unit Under Test (UUT)
  encoder #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) uut (
    .clk(clk),
    .cs(cs),
    .rst_n(rst_n)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test stimulus
  initial begin
    // Initialize inputs
    clk = 0;
    rst_n = 1;
    cs = 0;

    // Apply reset
    #10 rst_n = 0;
    #10 rst_n = 1;
    #10 cs = 1;
    #6000;
    #10 $stop;
  end


  // Monitor
  always @(posedge clk) begin
    $display("Encoder State:%b", uut.state);
    $display("av=%b, ao=%b", uut.av, uut.ao);
    $display("ac=%b, ao_current_char=%b", uut.ac, uut.ao_current_char);
    $display("a_ouptut_code=%b", uut.a_ouptut_code);
    $display("Input Mem: %p", uut.input_ram.mem);
    $display("Output Mem: %p", uut.output_ram.mem);
    $display("Output code Mem: %p", uut.output_ram.mem);
    $display("------------------------------------------------------------------------------------------");
  end

endmodule