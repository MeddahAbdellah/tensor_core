`timescale 1ns/1ps

module matcher_tb;

  // Parameters
  parameter ADDR_WIDTH = 4;
  parameter WORD_LENGTH = 3;
  parameter DATA_WIDTH = 8;

  // Signals
  logic clk;
  logic rst_n;
  logic [WORD_LENGTH * DATA_WIDTH - 1 : 0] word;

  // Instantiate the Unit Under Test (UUT)
  matcher #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .WORD_LENGTH(WORD_LENGTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) uut (
    .clk(clk),
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
    word = {DATA_WIDTH*WORD_LENGTH{1'b0}};

    // Apply reset
    #10 rst_n = 0;
    #10 rst_n = 1;

    // Test case 1: Set a sample word
    #20 word = {8'h48, 8'h65, 8'h6C}; // ASCII for "Hel"

    #200;

    $display("all mem:%p", uut.vocab_ram.mem);
    // End simulation
    #10 $stop;
  end


  // Monitor
  always @(posedge clk) begin
    $display("rst_n:%b", rst_n);
    $display("Vocab: addr=%b, val=%b",
             uut.vocab_incr.curr_addr, uut.vocab_ram.dout);
    $display("Input: addr=%b, val=%b",
             uut.input_incr.curr_addr, uut.input_ram.dout);
    $display("vocab_overflow=%b, nullptr_vocab=%b, input_overflow=%b, nullptr_input=%b",
             uut.vocab_overflow, uut.nullptr_vocab, uut.input_overflow, uut.nullptr_input);
    $display("------------------------------------------------------------------------------------------");
  end

endmodule