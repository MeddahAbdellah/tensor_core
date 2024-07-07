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

    logic start_addr = 0;
    logic end_addr = 0;

    logic [2:0] state = 0;
    logic [ADDR_WIDTH-1: 0] av = 0;
    logic [ADDR_WIDTH-1: 0] ai;

    logic vocab_overflow;
    logic nullptr_vocab;
    logic nullptr_input;
    logic equal;

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\vocab.bin")
    ) vocab_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(av)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\word.bin")
    ) input_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(ai)
    );

    assign equal = (vocab_ram.dout === input_ram.dout);
    assign nullptr_vocab = (vocab_ram.dout === 0);
    assign nullptr_input = (input_ram.dout === 0);
    assign vocab_overflow = (av === end_addr);

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            state <= 0;
            av <= start_addr;
            ai <= 0;
            d <= 0;
            e <= 0;
        end else begin
            case(state)
                3'b000: begin
                    av <= start_addr;
                    ai <= 0;
                    if(cs) begin
                        state <= 3'b001;
                    end else begin
                        state <= state;
                    end
                    d <= d;
                    e <= 0;
                end
                3'b001: begin
                    av <= av + 1;
                    ai <= ai + 1;
                    if ((nullptr_input && equal) || vocab_overflow) begin
                        state <= 3'b101;
                    end else if(!equal) begin
                        state <= 3'b011;
                    end else if(nullptr_vocab) begin
                        state <= 3'b010;
                    end else begin
                        state <= state;
                    end
                    d <= d;
                    e <= 0;
                end
                3'b010: begin
                    av <= av;
                    ai <= 0;
                    state <= 3'b001;
                    d <= d;
                    e <= 0;
                end
                3'b011: begin
                    av <= av;
                    ai <= 0;
                    if (nullptr_vocab) begin
                        state <= 3'b001;
                    end else begin
                        state <= 3'b100;
                    end
                    d <= d;
                    e <= 0;
                end
                3'b100: begin
                    av <= av + 1;
                    ai <= 0;
                    if (nullptr_vocab) begin
                        state <= 3'b001;
                    end else begin
                        state <= state;
                    end
                    d <= d;
                    e <= 0;
                end
                3'b101: begin
                    av <= av;
                    ai <= ai;
                    state <= state;
                    d <= 1;
                    e <= equal;
                end
                default: begin
                    av <= av;
                    ai <= ai;
                    state <= state;
                    d <= d;
                    e <= equal;
                end
            endcase
        end
    end

endmodule