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
  matcher #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .WORD_LENGTH(WORD_LENGTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) uut (
    .clk(clk),
    .cs(cs),
    .rst_n(rst_n),
    .vocab_start_addr(0),
    .vocab_end_addr(4'b1111),
    .input_start_addr(0),
    .val_vocab(vocab_ram.dout),
    .val_input(input_ram.dout)
  );

  sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\vocab.bin")
    ) vocab_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(matcher.addr_v)
    );

  sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\word.bin")
    ) input_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(matcher.addr_i)
    );

  // Clock generation
  always #5 clk = ~clk;

  // Test stimulus
  initial begin
    // Initialize inputs
    clk = 0;
    rst_n = 1;
    cs = 0;
    #10 rst_n = 0;
    #10 rst_n = 1;
    #10 cs = 1;
    #550;
    #10 $stop;
  end


  // Monitor
  always @(posedge clk) begin
    $display("rst_n:%b, cs:%b", uut.rst_n, uut.cs);
    $display("Vocab: addr=%b, val=%b",
             uut.av, uut.val_vocab);
    $display("Input: addr=%b, val=%b",
             uut.ai, uut.val_input);
    $display("state=%b, equal=%b, nullptr_vocab=%b, nullptr_input=%b, vocab_overflow=%b, end_addr=%b",
             uut.state, uut.e, uut.npv, uut.npi, uut.vo, uut.vocab_end_addr);
    $display("FOUND=%b, DONE=%b",
             uut.found, uut.done);
    $display("------------------------------------------------------------------------------------------");
  end

endmodule