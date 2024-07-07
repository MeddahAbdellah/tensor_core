module matcher#(
    parameter ADDR_WIDTH = 4,
    parameter WORD_LENGTH = 3,
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    input logic cs,
    input logic [WORD_LENGTH * DATA_WIDTH -1: 0] word
);

    logic d;
    logic e;


    logic [2:0] state = 0;
    logic input_incr_rst_n;
    logic vocab_cs;
    logic input_cs;

    logic input_overflow;
    logic vocab_overflow;
    logic nullptr_vocab;
    logic nullptr_input;
    logic equal;

    char_incr #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) vocab_incr(
        .clk(clk),
        .rst_n(rst_n),
        .cs(vocab_cs),
        .start_addr(0),
        .end_addr(15),
        .overflow(vocab_overflow)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\vocab.bin")
    ) vocab_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(vocab_incr.curr_addr)
    );

    char_incr #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) input_incr(
        .clk(clk),
        .rst_n(input_incr_rst_n),
        .cs(input_cs),
        .start_addr(0),
        .end_addr(15),
        .overflow(input_overflow)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\word.bin")
    ) input_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(input_incr.curr_addr)
    );

    assign equal = (vocab_ram.dout === input_ram.dout);
    assign nullptr_vocab = (vocab_ram.dout === 0);
    assign nullptr_input = (input_ram.dout === 0);

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            state <= 0;
            vocab_cs <= 0;
            input_cs <= 0;
            d <= 0;
            input_incr_rst_n <= 0;
        end else begin
            case(state)
                3'b000: begin
                    vocab_cs <= 0;
                    input_cs <= 0;
                    if(cs) begin
                        state <= 3'b001;
                    end else begin
                        state <= state;
                    end
                    d <= d;
                    e <= equal;
                    input_incr_rst_n <= input_incr_rst_n;
                end
                3'b001: begin
                    vocab_cs <= 1;
                    input_cs <= 1;
                    input_incr_rst_n <= 1;
                    if ((nullptr_input && equal) || vocab_overflow) begin
                        state <= 3'b110;
                    end else if(!equal) begin
                        state <= 3'b011;
                    end if(nullptr_vocab) begin
                        state <= 3'b010;
                    end else begin
                        state <= state;
                    end
                    d <= d;
                    e <= equal;
                end
                3'b010: begin
                    vocab_cs <= 0;
                    input_cs <= 0;
                    input_incr_rst_n <= 0;
                    state <= 3'b001;
                    d <= d;
                    e <= equal;
                end
                3'b011: begin
                    vocab_cs <= 1;
                    input_cs <= 0;
                    input_incr_rst_n <= 0;
                    if (nullptr_vocab) begin
                        state <= 3'b101;
                    end else begin
                        state <= 3'b100;
                    end
                    d <= d;
                    e <= equal;
                end
                3'b100: begin
                    vocab_cs <= 1;
                    input_cs <= 0;
                    input_incr_rst_n <= 1;
                    if (nullptr_vocab) begin
                        state <= 3'b101;
                    end else begin
                        state <= state;
                    end
                    d <= d;
                    e <= equal;
                end
                3'b101: begin
                    vocab_cs <= 0;
                    input_cs <= 0;
                    input_incr_rst_n <= 1;
                    state <= 3'b001;
                    d <= d;
                    e <= equal;
                end
                3'b110: begin
                    d <= 1;
                    e <= equal;
                end
            endcase
        end
    end

endmodule