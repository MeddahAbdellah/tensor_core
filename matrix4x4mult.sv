module matrix4x4mult (
    input logic [15:0] A[15:0], // 16 inputs of 16 bits each
    input logic [15:0] B[15:0], // 16 inputs of 16 bits each
    output logic [31:0] C[15:0] // 16 outputs of 32 bits each
);

    logic [31:0] mult_result[63:0]; // Results of 64 multiplications

    reg [31:0] result[15:0];
    genvar i;

    // Multiplication instances
    generate
        for (i = 0; i < 64; i = i + 1) begin : multipliers
                fp16to32mult mult_instance (
                    .a(A[4 * (i/16) + (i%4)]),
                    .b(B[(i/4)%4 +  4 * (i%4)]),
                    .result(mult_result[i])
                );
        end
    endgenerate

    // Addition instances
    generate
        for (i = 0; i < 16; i = i + 1) begin : adders
    		fp32_4number_adder add_4_instance (
        		.a(mult_result[4 * i]),
        		.b(mult_result[4 * i + 1]),
        		.c(mult_result[4 * i + 2]),
        		.d(mult_result[4 * i + 3]),
        		.result(result[i])
    		);
        end
    endgenerate

    assign C = result;
endmodule
