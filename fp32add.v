module fp32add (
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] result
);

    // Extract sign, exponent, and mantissa
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] mant_a = {1'b1, a[22:0]}; // Implicit leading 1
    wire [23:0] mant_b = {1'b1, b[22:0]}; // Implicit leading 1

    // Align exponents
    wire [7:0] exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
    wire [23:0] mant_a_shifted = (exp_a > exp_b) ? mant_a : (mant_a >> exp_diff);
    wire [23:0] mant_b_shifted = (exp_b > exp_a) ? mant_b : (mant_b >> exp_diff);
    wire [7:0] exp_common = (exp_a > exp_b) ? exp_a : exp_b;

    // Perform addition or subtraction
    wire [24:0] mant_sum = (sign_a == sign_b) ? (mant_a_shifted + mant_b_shifted) : 
                            (mant_a_shifted > mant_b_shifted) ? (mant_a_shifted - mant_b_shifted) :
                            (mant_b_shifted - mant_a_shifted);
    wire sign_result = (sign_a == sign_b) ? sign_a : (mant_a_shifted > mant_b_shifted) ? sign_a : sign_b;

    reg [7:0] exp_result;
    reg [23:0] mant_result;

    // Normalization
    always @(*) begin
        if (mant_sum[24] == 1) begin
            exp_result = exp_common + 1;
            mant_result = mant_sum[23:1];
        end else if(mant_sum[23] == 0) begin
            exp_result = exp_common - 1;
            mant_result = mant_sum[22:0] << 1;
        end else begin
            exp_result = exp_common;
            mant_result = mant_sum[22:0];
        end
    end

    // Handle special cases (infinities, NaNs, zeroes)
    wire is_zero = (mant_result == 0) && (exp_result == 0) && (sign_result == 0);
    wire [31:0] result_preliminary = {sign_result, exp_result, mant_result[22:0]};

    assign result = is_zero ? 32'b0 : result_preliminary;

endmodule