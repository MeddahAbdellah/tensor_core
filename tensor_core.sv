module tensor_core (
    input logic clk,                      // Clock signal
    input logic rst_n,                    // Active low reset
    input logic serial_in_a,                // Serial input
    input logic serial_in_b,                // Serial input
    output logic serial_out,              // Serial output
    output logic done                     // Indicate operation completion
);
    logic [15:0] A [15:0];
    logic [15:0] B [15:0];
    logic [31:0] C [15:0];
    logic [7:0] bit_cnt;
    logic [4:0] index;
    logic [31:0] temp_out;
    logic serial_out_en;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt <= 0;
            index <= 0;
            serial_out_en <= 0;
        end else begin
            if (index < 16) begin
                if (bit_cnt < 16) begin
                    A[index][bit_cnt] <= serial_in_a;
                    B[index][bit_cnt] <= serial_in_b;
                    bit_cnt <= bit_cnt + 1;
                end else begin
                    bit_cnt <= 0;
                    index <= index + 1;
                end
            end else begin
                serial_out_en <= 1;
                bit_cnt <= bit_cnt + 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (serial_out_en) begin
            if (bit_cnt < 32) begin
                serial_out <= C[index][bit_cnt];
                bit_cnt <= bit_cnt + 1;
            end else begin
                bit_cnt <= 0;
                index <= index + 1;
            end
        end
    end

    assign done = (index == 16);

    matrix4x4mult matrix4x4mult_instance (
        .A(A),
        .B(B),
        .C(C)
    );

endmodule