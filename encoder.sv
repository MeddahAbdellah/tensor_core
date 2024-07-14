module encoder#(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
) (
    input logic clk,
    input logic cs,
    input logic rst_n,
    output logic done
);
      grouper #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
      ) grouper (
        .clk(clk),
        .cs(cs),
        .rst_n(rst_n),
        .val_output(output_ram.dout),
        .val_input(input_ram.dout),
        .val_vocab(vocab_ram.dout)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\vocab.bin")
    ) vocab_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(grouper.matcher.addr_v)
    );
    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\vocab.bin")
    ) code_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(grouper.matcher.addr_v)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\word.bin")
    ) input_ram (
        .clk(clk),
        .cs(1'b1),
        .we(grouper.ow),
        .addr(grouper.ai),
        .din(output_ram.dout)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) output_ram (
        .clk(clk),
        .cs(1'b1),
        .we(grouper.w),
        .din(input_ram.dout),
        .addr(grouper.ao)
    );
endmodule