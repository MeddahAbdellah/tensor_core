module matcher#(
    parameter ADDR_WIDTH = 4,
    parameter WORD_LENGTH = 3,
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    input logic [WORD_LENGTH * DATA_WIDTH -1: 0] word
);

    logic nullptr_vocab;
    logic vocab_overflow;

    char_incr #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) vocab_incr(
        .clk(clk),
        .rst_n(rst_n),
        .start_addr(0),
        .end_addr(15),
        .curr_addr(curr_vocab_addr),
        .overflow(vocab_overflow)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\verilog_work\\tensor_core\\vocab.bin")
    ) vocab_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(vocab_incr.curr_addr)
    );

    assign nullptr_vocab = (vocab_ram.dout === 0);
endmodule