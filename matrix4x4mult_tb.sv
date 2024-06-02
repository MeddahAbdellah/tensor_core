`timescale 1ns / 1ps

module tb_matrix4x4mult;

    // Inputs
    logic [15:0] A[15:0];
    logic [15:0] B[15:0];
    logic [31:0] C[15:0];
    // Instantiate the matrix_multiplication module
    matrix4x4mult uut (
        .A(A),
        .B(B),
        .C(C)
    );

    // Initialize inputs
    initial begin
        // Initialize matrix A with some 16-bit floating point values
        // Matrix A (in 16-bit floating point):
        // 1.0  2.0  3.0  4.0
        // 5.0  6.0  7.0  8.0
        // 10.0 12.0 14.0 16.0
        // 20.0 24.0 28.0 32.0
        A[0] = 16'h3C00; A[1] = 16'h4000; A[2] = 16'h4200; A[3] = 16'h4400;
        A[4] = 16'h4500; A[5] = 16'h4600; A[6] = 16'h4700; A[7] = 16'h4800;
        A[8] = 16'h4900; A[9] = 16'h4A00; A[10] = 16'h4B00; A[11] = 16'h4C00;
        A[12] = 16'h4D00; A[13] = 16'h4E00; A[14] = 16'h4F00; A[15] = 16'h5000;

        // Initialize matrix B with some 16-bit floating point values
        // Matrix B (in 16-bit floating point):
        //32.0 28.0 24.0 20.0
        //16.0 14.0 12.0  10.0
        // 8.0  7.0  6.0  5.0
        // 4.0  3.0  2.0  1.0
        B[0] = 16'h5000; B[1] = 16'h4F00; B[2] = 16'h4E00; B[3] = 16'h4D00;
        B[4] = 16'h4C00; B[5] = 16'h4B00; B[6] = 16'h4A00; B[7] = 16'h4900;
        B[8] = 16'h4800; B[9] = 16'h4700; B[10] = 16'h4600; B[11] = 16'h4500;
        B[12] = 16'h4400; B[13] = 16'h4200; B[14] = 16'h4000; B[15] = 16'h3C00;

        // Wait for the multiplication and addition to complete
        #100;

        // Display the output matrix C
        // The expected results should be verified based on the floating point operations
        $display("Output Matrix C:");
        $display("%h %h %h %h", C[0], C[1], C[2], C[3]);
        $display("%h %h %h %h", C[4], C[5], C[6], C[7]);
        $display("%h %h %h %h", C[8], C[9], C[10], C[11]);
        $display("%h %h %h %h", C[12], C[13], C[14], C[15]);

        // Finish the simulation
        $stop;
    end

endmodule