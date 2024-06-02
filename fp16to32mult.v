module fp16to32mult(
    input [15:0] a,
    input [15:0] b,
    output [31:0] result
    );

    // Extract fields of the 16-bit floating-point numbers
    wire sign_a = a[15];
    wire [4:0] exp_a = a[14:10];
    wire [9:0] mantissa_a = a[9:0];

    wire sign_b = b[15];
    wire [4:0] exp_b = b[14:10];
    wire [9:0] mantissa_b = b[9:0];

    // Calculate the sign of the result
    wire sign_result = sign_a ^ sign_b;

    // Special cases handling
    wire a_is_zero = (exp_a == 0) && (mantissa_a == 0);
    wire b_is_zero = (exp_b == 0) && (mantissa_b == 0);
    wire a_is_nan = (exp_a == 5'b11111) && (mantissa_a != 0);
    wire b_is_nan = (exp_b == 5'b11111) && (mantissa_b != 0);
    wire a_is_inf = (exp_a == 5'b11111) && (mantissa_a == 0);
    wire b_is_inf = (exp_b == 5'b11111) && (mantissa_b == 0);

    // Handle special cases
    reg [31:0] special_result;
    always @(*) begin
        if (a_is_nan || b_is_nan) begin
            special_result = {sign_result, 8'b11111111, 23'b1}; // NaN
        end else if (a_is_zero || b_is_zero) begin
            special_result = {sign_result, 8'b0, 23'b0}; // Zero
        end else if (a_is_inf || b_is_inf) begin
            if (a_is_zero || b_is_zero) begin
                special_result = {sign_result, 8'b11111111, 23'b1}; // NaN
            end else begin
                special_result = {sign_result, 8'b11111111, 23'b0}; // Infinity
            end
        end else begin
            special_result = 32'b0; // Default value for non-special cases
        end
    end

    // Calculate exponent and mantissa for non-special cases
    wire [7:0] exp = exp_a + exp_b - 5'b11110 + 8'b01111111;
    wire [21:0] mantissa_product = {1'b1, mantissa_a} * {1'b1, mantissa_b};

    // Temporary variables for normalization
    reg [7:0] final_exp;
    reg [21:0] temp_result;

    always @(*) begin
        // Normalization process
        if (mantissa_product[21] == 1) begin
            final_exp = exp + 1;
            temp_result = mantissa_product >> 1;
        end else begin
            final_exp = exp;
            temp_result = mantissa_product;
        end
    end

    // Construct the final result for non-special cases
    wire [31:0] normal_result = {sign_result, final_exp, temp_result[19:0], 3'b0};

    // Assign the correct result a = boolean ? 1 : 2;
    assign result = (a_is_nan || b_is_nan || a_is_zero || b_is_zero || a_is_inf || b_is_inf) ? special_result : normal_result;

endmodule