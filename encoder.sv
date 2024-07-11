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
    E15
} encoder_state;

module encoder#(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
) (
    input logic clk,
    input logic cs,
    input logic rst_n
);
    logic rs_n;
    logic ccs;
    logic [DATA_WIDTH - 1: 0] aw;
    logic [DATA_WIDTH - 1: 0] ar;
    logic [DATA_WIDTH - 1: 0] ao;
    logic [DATA_WIDTH - 1: 0] ai;
    logic npv;
    logic w;
    encoder_state state;

    matcher #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) matcher (
        .clk(clk),
        .cs(cs),
        .rst_n(~(rst_n & rs_n)),
        .input_start_addr(ar),
        .vocab_start_addr(0),
        .vocab_end_addr(4'b1111),
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
        .ADDR_WIDTH(ADDR_WIDTH)
    ) output_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b1),
        .addr(ao)
    );

    assign npv = (input_ram.dout === 0);
    assign ai = matcher.done ? (w ? aw : ar) : matcher.addr_i;
     
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= E0;
            rs_n <= 0;
            ccs <= 0;
            aw <= 0;
            ar <= 0;
            w <= 0;
        end else begin
            case(state)
                E0: begin
                    rs_n <= 0;
                    ccs <= 0;
                    aw <= aw;
                    ar <= ar;
                    ao <= ao;
                    w <= 0;
                    if(cs) begin
                        state <= E1;
                    end else begin
                        state <= state;
                    end
                end
                E1: begin
                    rs_n <= 1;
                    ccs <= 1;
                    aw <= aw;
                    ar <= ar;
                    ao <= ao;
                    w <= w;
                    state <= E2;
                end
                E2: begin
                    rs_n <= rs_n;
                    ccs <= ccs;
                    aw <= aw;
                    ao <= ao;
                    w <= w;
                    if (matcher.done & !matcher.found) begin
                        ar <= ar + 1;
                        state <= E3;
                    end else begin
                        ar <= ar;
                        state <= E2;
                    end
                end
                E3: begin
                    rs_n <= rs_n;
                    ccs <= ccs;
                    ar <= ar;
                    if (npv) begin
                        aw <= aw;
                        ao <= ao;
                        w <= w;
                        state <= E4;
                    end else begin
                        aw <= aw + 1;
                        ao <= ao + 1;
                        w <= 1;
                        state <= E5;
                    end
                end
                E4: begin
                    rs_n <= rs_n;
                    ccs <= ccs;
                    aw <= aw;
                    ao <= ao;
                    w <= w;
                    ar <= ar + 1;
                    state <= E3;
                end
                E5: begin
                    ar <= ar;
                    aw <= aw;
                    ao <= ao;
                    if (npv) begin
                        w <= 0;
                        rs_n <= 0;
                        ccs <= 0;
                        state <= E1;
                    end else begin
                        w <= w;
                        rs_n <= rs_n;
                        ccs <= ccs;
                        state <= E6;
                    end
                end
                E4: begin
                    rs_n <= rs_n;
                    ccs <= ccs;
                    aw <= aw + 1;
                    ao <= ao + 1;
                    w <= w;
                    ar <= ar;
                    state <= E3;
                end
                default: begin
                    rs_n <= rs_n;
                    ccs <= ccs;
                    aw <= aw;
                    ao <= ao;
                    ar <= ar;
                    w <= w;
                    state <= state;
                end
            endcase
        end
        
    end

endmodule