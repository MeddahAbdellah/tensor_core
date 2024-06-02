`timescale 1ns / 1ps

module tb_fp32add;

    // Inputs
    reg [31:0] a;
    reg [31:0] b;

    // Outputs
    wire [31:0] result;

    // Instantiate the Unit Under Test (UUT)
    fp32add uut (
        .a(a),
		  .b(b),
        .result(result)
    );
	 

    initial begin
        // Initialize Inputs
        a = 32'b0;
        b = 32'b0;

        // Test cases
        // Test case 1: Adding two positive numbers
        #10;
        a = 32'h40400000; // 3.0
        b = 32'h40800000; // 4.0
        #10;
        $display("a: %h, b: %h, result: %h", a, b, result); // Expect 32'h40A00000 (7.0)

        // Test case 2: Adding a positive and a negative number
        #10;
        a = 32'h40400000; // 3.0
        b = 32'hC0000000; // -2.0
        #10;
        $display("a: %h, b: %h, result: %h", a, b, result); // Expect 32'h3F800000 (1.0)

        // Test case 3: Adding two negative numbers
        #10;
        a = 32'hC0400000; // -3.0
        b = 32'hC0800000; // -4.0
        #10;
        $display("a: %h, b: %h, result: %h", a, b, result); // Expect 32'hC0A00000 (-7.0)

        // Test case 4: Adding a number and zero
        #10;
        a = 32'h40400000; // 3.0
        b = 32'h00000000; // 0.0
        #10;
        $display("a: %h, b: %h, result: %h", a, b, result); // Expect 32'h40400000 (3.0)

        // Test case 5: Adding zero and zero
        #10;
        a = 32'h00000000; // 0.0
        b = 32'h00000000; // 0.0
        #10;
        $display("a: %h, b: %h, result: %h", a, b, result); // Expect 32'h00000000 (0.0)

        // Test case 6: Adding two large positive numbers
        #10;
        a = 32'h7F800000; // Infinity
        b = 32'h7F800000; // Infinity
        #10;
        $display("a: %h, b: %h, result: %h", a, b, result); // Expect 32'h7F800000 (Infinity)

        // Test case 7: Adding a positive number and Infinity
        #10;
        a = 32'h40400000; // 3.0
        b = 32'h7F800000; // Infinity
        #10;
        $display("a: %h, b: %h, result: %h", a, b, result); // Expect 32'h7F800000 (Infinity)

        // Test case 8: Adding a negative number and Infinity
        #10;
        a = 32'hC0400000; // -3.0
        b = 32'h7F800000; // Infinity
        #10;
        $display("a: %h, b: %h, result: %h", a, b, result); // Expect 32'h7F800000 (Infinity)

        // Test case 9: Adding NaN and a number
        #10;
        a = 32'h7FC00000; // NaN
        b = 32'h40400000; // 3.0
        #10;
        $display("a: %h, b: %h, result: %h", a, b, result); // Expect 32'h7FC00000 (NaN)

        // Test case 10: Adding NaN and NaN
        #10;
        a = 32'h7FC00000; // NaN
        b = 32'h7FC00000; // NaN
        #10;
        $display("a: %h, b: %h, result: %h", a, b, result); // Expect 32'h7FC00000 (NaN)

        // Test complete
        #10;
        $stop;
    end

endmodule