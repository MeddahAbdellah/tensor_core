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
    logic nullptr_input;
    logic vocab_overflow;
    logic input_overflow;
    logic equal;
    logic m_clk;
    logic blocker_sig;
    logic blocked;
    logic blocker_clk;
    logic input_incr_rst_n;

    char_incr #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) vocab_incr(
        .clk(m_clk),
        .rst_n(rst_n),
        .start_addr(0),
        .end_addr(15),
        .overflow(vocab_overflow)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\vocab.bin")
    ) vocab_ram (
        .clk(m_clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(vocab_incr.curr_addr)
    );

    char_incr #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) input_incr(
        .clk(blocker_sig),
        .rst_n(input_incr_rst_n),
        .start_addr(0),
        .end_addr(15),
        .overflow(input_overflow)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\word.bin")
    ) input_ram (
        .clk(m_clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(input_incr.curr_addr)
    );

    assign equal = (vocab_ram.dout === input_ram.dout);
    assign input_incr_rst_n = rst_n & equal;
    assign nullptr_vocab = (vocab_ram.dout === 0);
    assign nullptr_input = ((input_ram.dout === 0) && equal);
    assign m_clk = (clk && !nullptr_input);
    assign blocker_clk = (!blocked && nullptr_vocab) || (blocked & !equal);
    assign blocker_sig = (m_clk && blocked);

    always_ff @(posedge blocker_clk or negedge rst_n) begin
        if(!rst_n) begin 
            blocked <= 1'b1;
        end else begin
            blocked <= !blocked;
        end
    end

endmodule