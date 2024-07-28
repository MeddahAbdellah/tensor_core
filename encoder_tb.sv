`timescale 1ns/1ps

module encoder_tb;

  // Parameters
  parameter ADDR_WIDTH = 4;
  parameter VOCAB_ADDR_WIDTH = 5;
  parameter DATA_WIDTH = 8;

  // Signals
  logic clk;
  logic rst_n;
  logic cs;
  integer clk_cycle_count;

  // Instantiate the Unit Under Test (UUT)
  encoder #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .VOCAB_ADDR_WIDTH(VOCAB_ADDR_WIDTH),
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
    // Wait for done signal
    wait (uut.done == 1);
    #10;
    $display("Number of clock cycles: %0d", clk_cycle_count);
    $stop;
  end


  // Monitor
  always @(posedge clk) begin
    if(uut.done == 0) begin
        clk_cycle_count = clk_cycle_count + 1;
        $display("Encoder State:%b", uut.state);
        $display("Grouper State:%b", uut.grouper.state);
        $display("Grouper OW:%b", uut.grouper.ow);
        $display("av=%b, ao=%b", uut.av, uut.ao);
        $display("ac=%b, ao_current_char=%b", uut.ac, uut.ao_current_char);
        $display("a_output_code=%b", uut.a_output_code);
        $display("e=%b, npo=%b, npv=%b", uut.e, uut.npo, uut.npv);
        $display("Input Mem: %p", uut.input_ram.mem);
        $display("Output Mem: %p", uut.output_ram.mem);
        $display("Output code Mem: %p", uut.output_code_ram.mem);
        $display("------------------------------------------------------------------------------------------");
    end
  end

endmodule