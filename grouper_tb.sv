`timescale 1ns/1ps

module grouper_tb;

  // Parameters
  parameter ADDR_WIDTH = 4;
  parameter DATA_WIDTH = 8;

  // Signals
  logic clk;
  logic rst_n;
  logic cs;

  // Instantiate the Unit Under Test (UUT)
  grouper #(
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
    #4000;
    #10 $stop;
  end


  // Monitor
  always @(posedge clk) begin
    $display("rst_n:%b, cs:%b", uut.matcher.rst_n, uut.matcher.cs);
    $display("SRAM Vocab: addr=%b, val=%b",
             uut.vocab_ram.addr, uut.vocab_ram.dout);
    $display("SRAM Input: addr=%b, val=%b, ow=%b",
             uut.input_ram.addr, uut.input_ram.dout, uut.input_ram.we);
    $display("Grouper State:%b", uut.state);
    $display("Matcher State:%b", uut.matcher.state);
    $display("Matcher Vocab: addr=%b, val=%b",
             uut.matcher.av, uut.matcher.val_vocab);
    $display("Matcher Input: addr=%b, val=%b",
             uut.matcher.ai, uut.matcher.val_input);
    $display("FOUND=%b, DONE=%b",
             uut.matcher.found, uut.matcher.done);
    $display("ar=%b, aw=%b, ao=%b, w=%b",
             uut.ar, uut.aw, uut.ao, uut.w);
    $display("ai=%b, npv=%b",
             uut.ai, uut.npv);
    $display("GROUPER DONE=%b, s=%b",
             uut.done, uut.s);
    $display("Input Mem: %p", uut.input_ram.mem);
    $display("Output Mem: %p", uut.output_ram.mem);
    $display("------------------------------------------------------------------------------------------");
  end

endmodule