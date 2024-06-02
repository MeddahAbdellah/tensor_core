`timescale 1ns / 1ps

module tb_fp32_4number_adder;
    reg [31:0] a, b, c, d;
    wire [31:0] result;

    fp32_4number_adder uut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .result(result)
    );

    initial begin
        // Test case 1
        a = 32'h3f800000; // 1.0
        b = 32'h40000000; // 2.0
        c = 32'h40400000; // 3.0
        d = 32'h40800000; // 4.0
        #10;
        $display("Result: %h", result);

        // Add more test cases as needed

        $stop;
    end
endmodule