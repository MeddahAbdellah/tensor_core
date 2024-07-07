`timescale 1ns/1ps

module matcher_tb;

  // Parameters
  parameter ADDR_WIDTH = 4;
  parameter WORD_LENGTH = 3;
  parameter DATA_WIDTH = 8;

  // Signals
  logic clk;
  logic rst_n;
  logic cs;
  logic [WORD_LENGTH * DATA_WIDTH - 1 : 0] word;

  // Instantiate the Unit Under Test (UUT)
  matcher #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .WORD_LENGTH(WORD_LENGTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) uut (
    .clk(clk),
    .cs(cs),
    .rst_n(rst_n),
    .word(word)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test stimulus
  initial begin
    // Initialize inputs
    clk = 0;
    rst_n = 1;
    cs = 0;
    word = {DATA_WIDTH*WORD_LENGTH{1'b0}};

    // Apply reset
    #10 rst_n = 0;
    #10 rst_n = 1;

    // Test case 1: Set a sample word
    #20 word = {8'h48, 8'h65, 8'h6C}; // ASCII for "Hel"

    #10 cs = 1;
    #250;

    $display("all mem:%p", uut.vocab_ram.mem);
    // End simulation
    #10 $stop;
  end


  // Monitor
  always @(posedge clk) begin
    $display("rst_n:%b, cs:%b", uut.rst_n, uut.cs);
    $display("Vocab: addr=%b, val=%b",
             uut.av, uut.vocab_ram.dout);
    $display("Input: addr=%b, val=%b",
             uut.ai, uut.input_ram.dout);
    $display("state=%b, equal=%b, nullptr_vocab=%b, nullptr_input=%b, vocab_overflow=%b, end_addr=%b",
             uut.state, uut.equal, uut.nullptr_vocab, uut.nullptr_input, uut.vocab_overflow, uut.end_addr);
    $display("FOUND=%b, DONE=%b",
             uut.found, uut.done);
    $display("------------------------------------------------------------------------------------------");
  end

endmodule