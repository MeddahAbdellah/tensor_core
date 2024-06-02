`timescale 1ns / 1ps

module tb_fp16to32mult;

// Inputs
reg [15:0] a;
reg [15:0] b;

// Outputs
wire [31:0] result;

// Instantiate the Unit Under Test (UUT)
fp16to32mult uut (
    .a(a), 
    .b(b), 
    .result(result)
);

initial begin
    // Initialize Inputs and apply test vectors

    // Test 1: 1.0 * 2.0
    a = 16'h3C00; // 1.0 in 16-bit floating point
    b = 16'h4000; // 2.0 in 16-bit floating point
    #10;
    $display("Test 1: a = %h, b = %h, result = %h", a, b, result);

    // Test 2: -2.0 * 1.0
    a = 16'hC000; // -2.0 in 16-bit floating point
    b = 16'h3C00; // 1.0 in 16-bit floating point
    #10;
    $display("Test 2: a = %h, b = %h, result = %h", a, b, result);

    // Test 3: 4.0 * 4.0
    a = 16'h4200; // 4.0 in 16-bit floating point
    b = 16'h4200; // 4.0 in 16-bit floating point
    #10;
    $display("Test 3: a = %h, b = %h, result = %h", a, b, result);

    // Test 4: 0.5 * 2.0
    a = 16'h3800; // 0.5 in 16-bit floating point
    b = 16'h4000; // 2.0 in 16-bit floating point
    #10;
    $display("Test 4: a = %h, b = %h, result = %h", a, b, result);

    // Test 5: 0.0 * 1.0
    a = 16'h0000; // 0.0 in 16-bit floating point
    b = 16'h3C00; // 1.0 in 16-bit floating point
    #10;
    $display("Test 5: a = %h, b = %h, result = %h", a, b, result);

    // Test 6: 1.0 * -Inf
    a = 16'h3C00; // 1.0 in 16-bit floating point
    b = 16'hFC00; // -Inf in 16-bit floating point
    #10;
    $display("Test 6: a = %h, b = %h, result = %h", a, b, result);

    // Test 7: -1.0 * -1.0
    a = 16'hBC00; // -1.0 in 16-bit floating point
    b = 16'hBC00; // -1.0 in 16-bit floating point
    #10;
    $display("Test 7: a = %h, b = %h, result = %h", a, b, result);

    // Test 8: Subnormal number * 2.0
    a = 16'h0400; // Small subnormal number in 16-bit floating point
    b = 16'h4000; // 2.0 in 16-bit floating point
    #10;
    $display("Test 8: a = %h, b = %h, result = %h", a, b, result);

    // Test 9: Max normal number * 0.5
    a = 16'h7BFF; // Max normal number in 16-bit floating point
    b = 16'h3800; // 0.5 in 16-bit floating point
    #10;
    $display("Test 9: a = %h, b = %h, result = %h", a, b, result);

    // Test 10: Smallest positive normal number * 1.0
    a = 16'h0400; // Smallest positive normal number in 16-bit floating point
    b = 16'h3C00; // 1.0 in 16-bit floating point
    #10;
    $display("Test 10: a = %h, b = %h, result = %h", a, b, result);

    // Finish simulation
    $stop;
end

endmodule