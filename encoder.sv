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
    DONE
} encoder_state;

module encoder#(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
) (
    input logic clk,
    input logic cs,
    input logic rst_n,
    output logic done,
);
    logic rs_n;
    logic ccs;
    logic [DATA_WIDTH - 1: 0] aw;
    logic [DATA_WIDTH - 1: 0] ar;
    logic [DATA_WIDTH - 1: 0] ao;
    logic [DATA_WIDTH - 1: 0] ai;
    logic npv;
    logic w;
    logic s;
    encoder_state state;

    matcher #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) matcher (
        .clk(clk),
        .cs(ccs),
        .rst_n(rst_n & rs_n),
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
        .addr(ai)
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
            ao <= 0;
            w <= 0;
            s <= 1;
            done <= 0;
        end else begin
            case(state)
                E0: begin
                    rs_n <= 0;
                    ccs <= 0;
                    aw <= aw;
                    ar <= ar;
                    ao <= ao;
                    w <= 0;
                    s <= 1;
                    if(cs) begin
                        state <= E1;
                    end else begin
                        state <= state;
                    end
                end
                E1: begin
                    done <= 0;
                    rs_n <= 1;
                    ccs <= 1;
                    aw <= aw;
                    ar <= ar;
                    ao <= ao;
                    w <= 0;
                    s <= 1;
                    state <= E2;
                end
                E2: begin
                    rs_n <= rs_n;
                    ccs <= ccs;
                    aw <= aw;
                    ar <= ar;
                    ao <= ao;
                    w <= 0;
                    if (matcher.done & !matcher.found) begin
                        s <= 1;
                        state <= E3;
                    end else begin
                        s <= s;
                        state <= E2;
                    end
                end
                E3: begin
                    rs_n <= rs_n;
                    ccs <= ccs;
                    s <= s;
                    ar <= ar + 1;
                    aw <= aw;
                    ao <= ao;
                    w <= w;
                    state <= E4;
                end
                E4: begin
                    rs_n <= rs_n;
                    ccs <= ccs;
                    s <= s;
                    aw <= aw;
                    ao <= ao;
                    ar <= ar;
                    if (npv) begin
                        w <= 1;
                        state <= E5;
                    end else begin
                        w <= w;
                        state <= E3;
                    end
                end
                E5: begin
                    ar <= ar;
                    w <= w;
                    s <= s;
                    rs_n <= rs_n;
                    aw <= aw + 1;
                    ao <= ao + 1;
                    ccs <= ccs;
                    state <= E6;
                end
                E6: begin
                    rs_n <= rs_n;
                    ccs <= ccs;
                    ar <= ar;
                    s <= s;
                    if (npv) begin
                        w <= w;
                        aw <= aw + 1;
                        ao <= ao + 1;
                        state <= E7;
                    end else begin
                        w <= 1;
                        aw <= aw;
                        ao <= ao;
                        state <= E5;
                    end
                end
                E7: begin
                    ar <= ar;
                    w <= 0;
                    rs_n <= 0;
                    s <= s;
                    aw <= aw;
                    ao <= ao;
                    ccs <= 0;
                    state <= E8;
                end
                E8: begin
                    w <= 0;
                    rs_n <= 0;
                    s <= s;
                    ccs <= 0;
                    if(npv) begin
                        ar <= 0;
                        aw <= 0;
                        ao <= 0;
                        state <= E9;
                    end else begin
                        ar <= ar;
                        aw <= aw;
                        ao <= ao;
                        state <= E1;
                    end
                end
                E9: begin
                    w <= 0;
                    rs_n <= 0;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ao <= ao;
                    ccs <= 0;
                    if(s) begin
                        state <= DONE;
                    end else begin
                        state <= E1;
                    end
                end
                DONE: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ao <= ao;
                    ccs <= ccs;
                    state <= state;
                    dont <= 1;
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