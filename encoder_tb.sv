`timescale 1ns/1ps

module matcher_tb;

  // Parameters
  parameter ADDR_WIDTH = 4;
  parameter DATA_WIDTH = 8;

  // Signals
  logic clk;
  logic rst_n;
  logic cs;

  // Instantiate the Unit Under Test (UUT)
  ecoder #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) uut (
    .clk(clk),
    .cs(cs),
    .rst_n(rst_n),
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
    #550;
    #10 $stop;
  end


  // Monitor
  always @(posedge clk) begin
    $display("rst_n:%b, cs:%b", uut.matcher.rst_n, uut.matcher.cs);
    $display("Vocab: addr=%b, val=%b",
             uut.matcher.av, uut.matcher.vocab_ram.dout);
    $display("Input: addr=%b, val=%b",
             uut.matcher.ai, uut.matcher.input_ram.dout);
    $display("state=%b, equal=%b, nullptr_vocab=%b, nullptr_input=%b, vocab_overflow=%b, end_addr=%b",
             uut.matcher.state, uut.matcher.equal, uut.matcher.nullptr_vocab, uut.matcher.nullptr_input, uut.matcher.vocab_overflow, uut.matcher.end_addr);
    $display("FOUND=%b, DONE=%b",
             uut.matcher.found, uut.matcher.done);
    $display("------------------------------------------------------------------------------------------");
  end

endmodule