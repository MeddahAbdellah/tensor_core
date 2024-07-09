module encoder#(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
) (
    input logic clk,
    input logic cs,
    input logic rst_n
);
    matcher #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) matcher (
        .clk(clk),
        .cs(cs),
        .rst_n(rst_n),
        .val_vocab(vocab_ram.dout),
        .val_input(input_ram.dout)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\vocab.bin")
    ) vocab_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(matcher.addr_v)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\word.bin")
    ) input_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(matcher.addr_i)
    );
endmodule