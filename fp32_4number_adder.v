module fp32_4number_adder(
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    input [31:0] d,
    output [31:0] result
);
    wire [31:0] sum1, sum2;

    fp32add add1 (.a(a), .b(b), .result(sum1));
    fp32add add2 (.a(c), .b(d), .result(sum2));
    fp32add add3 (.a(sum1), .b(sum2), .result(result));
endmodule