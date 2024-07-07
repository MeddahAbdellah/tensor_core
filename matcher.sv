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

    logic done;
    logic found;

    logic start_addr = 0;
    logic end_addr = 15;

    logic [1:0] state = 0;
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
            done <= 0;
            found <= 0;
        end else begin
            case(state)
                2'b00: begin
                    av <= start_addr;
                    ai <= 0;
                    if(cs) begin
                        state <= 2'b01;
                    end else begin
                        state <= state;
                    end
                    done <= done;
                    found <= 0;
                end
                2'b01: begin
                    if (nullptr_input && equal) begin
                        state <= 2'b11;
                        av <= av;
                        ai <= ai;
                        found <= 1;
                        done <= 1;
                    end else if (vocab_overflow) begin
                        state <= 2'b11;
                        av <= av;
                        ai <= ai;
                        found <= 0;
                        done <= 1;
                    end else if(!equal) begin
                        state <= 2'b10;
                        av <= av;
                        ai <= ai;
                        found <= 0;
                        done <= 0;
                    end else begin
                        state <= state;
                        av <= av + 1;
                        ai <= ai + 1;
                        found <= 0;
                        done <= 0;
                    end
                end
                2'b10: begin
                    ai <= 0;
                    if (nullptr_vocab) begin
                        state <= 2'b01;
                        av <= av;
                    end else begin
                        state <= state;
                        av <= av + 1;
                    end
                    done <= done;
                    found <= 0;
                end
                2'b11: begin
                    av <= av;
                    ai <= ai;
                    state <= state;
                    done <= 1;
                    found <= found;
                end
                default: begin
                    av <= av;
                    ai <= ai;
                    state <= state;
                    done <= done;
                    found <= found;
                end
            endcase
        end
    end

endmodule