module tensor_core (
    input logic [15:0] A[15:0], // 16 inputs of 16 bits each
    input logic [15:0] B[15:0], // 16 inputs of 16 bits each
    output logic [31:0] C[15:0] // 16 outputs of 32 bits each
);
    matrix4x4mult matrix4x4mult_instance (
        .A(A),
        .B(B),
        .C(C)
    );

endmodule