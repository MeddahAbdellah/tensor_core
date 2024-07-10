typedef enum logic [3:0] {
    E0,
    E1,
    E2,
    E3,
    E4,
    E5,
    E6,
    E7,
    E8,
    E9,
    E10,
    E11,
    E12,
    E13,
    E14,
    E15,
} state_t;

module encoder#(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
) (
    input logic clk,
    input logic cs,
    input logic rst_n
);
    logic rs;
    logic ccs;
    logic aw;
    logic ar;
    logic w;
    logic [DATA_WIDTH - 1: 0] buffer;
    state_t state;

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

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\word.bin")
    ) phrase_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(ar)
    );


     
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= E0;
            rs <= 0;
            ccs <= 0;
            aw <= 0;
            ar <= 0;
            w <= 0;
        end else begin
            case(state)
                E0: begin
                    rs <= 0;
                    ccs <= 0;
                    aw <= 0;
                    ar <= 0;
                    w <= 0;
                    if(cs) begin
                        state <= E1;
                    end else begin
                        state <= state;
                    end
                end
                E1: begin
                    rs <= 1;
                    ccs <= css;
                    aw <= aw;
                    ar <= ar;
                    w <= w;
                    state <= E2;
                end
                E2: begin
                    rs <= 1;
                    ccs <= css;
                    aw <= aw;
                    ar <= ar + 1;
                    w <= w;
                    if (input_ram.dout === 0) begin
                        state <= E3;
                    end else begin
                        state <= E2;
                    end
                end
            endcase
        end
        
    end

endmodule