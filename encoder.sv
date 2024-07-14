typedef enum logic [4:0] {
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
    E15_PATCH,
    E16,
    E17,
    E18,
    E19,
    E20,
    E21,
    E22,
    DONE
} encoder_state;

module encoder#(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
) (
    input logic clk,
    input logic cs,
    input logic rst_n,
    output logic done
);
    logic rs_n;
    logic ccs;
    logic [DATA_WIDTH - 1: 0] aw;
    logic [DATA_WIDTH - 1: 0] ar;
    logic [DATA_WIDTH - 1: 0] ao;
    logic [DATA_WIDTH - 1: 0] ai;
    logic npv;
    logic npo;
    logic w;
    logic s;
    logic ow;
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
        .we(ow),
        .addr(ai),
        .din(output_ram.dout)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) output_ram (
        .clk(clk),
        .cs(1'b1),
        .we(w),
        .din(input_ram.dout),
        .addr(ao)
    );

    assign npv = (input_ram.dout === 0);
    assign npo = (output_ram.dout === 0);
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
            ow <= 0;
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
                    ow <= 0;
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
                    ow <= 0;
                    state <= E2;
                end
                E2: begin
                    rs_n <= rs_n;
                    ccs <= ccs;
                    aw <= aw;
                    ar <= ar;
                    ao <= ao;
                    ow <= 0;
                    w <= 0;
                    if (matcher.done & !matcher.found) begin
                        s <= 1;
                        state <= E3;
                    end else if (matcher.done & matcher.found) begin
                        s <= 0;
                        state <= E10;
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
                    ow <= ow;
                    state <= E4;
                end
                E4: begin
                    rs_n <= rs_n;
                    ccs <= ccs;
                    s <= s;
                    aw <= aw;
                    ao <= ao;
                    ar <= ar;
                    ow <= ow;
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
                    w <= 1;
                    s <= s;
                    rs_n <= rs_n;
                    aw <= aw;
                    ao <= ao;
                    ccs <= ccs;
                    ow <= ow;
                    state <= E6;
                end
                E6: begin
                    ar <= ar;
                    w <= 1;
                    s <= s;
                    rs_n <= rs_n;
                    aw <= aw + 1;
                    ao <= ao + 1;
                    ccs <= ccs;
                    ow <= ow;
                    state <= E7;
                end
                E7: begin
                    ar <= ar;
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    aw <= aw;
                    ao <= ao;
                    ccs <= ccs;
                    ow <= ow;
                    if (npv) begin 
                        state <= E8;
                    end else begin
                        state <= E6;
                    end
                end
                E8: begin
                    w <= 0;
                    rs_n <= 0;
                    s <= s;
                    ccs <= 0;
                    ow <= ow;
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
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ao <= ao;
                    ccs <= ccs;
                    if(s) begin
                        ow <= ow;
                        state <= DONE;
                    end else begin
                        ow <= 1;
                        state <= E20;
                    end
                end
                E20: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar + 1;
                    aw <= aw;
                    ao <= ao + 1;
                    ccs <= ccs;
                    state <= E21;
                end
                E21: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ao <= ao;
                    ccs <= ccs;
                    ow <= ow;
                    if(npo) begin
                        state <= E22;
                    end else begin
                        state <= E20;
                    end
                end
                E22: begin
                    w <= w;
                    rs_n <= rs_n;
                    ccs <= ccs;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ao <= ao;
                    ow <= ow;
                    if(npo) begin
                        w <= 0;
                        rs_n <= 0;
                        ccs <= 0;
                        state <= E1;
                    end else begin
                        w <= w;
                        rs_n <= rs_n;
                        ccs <= ccs;
                        state <= E21;
                    end
                end
                DONE: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ao <= ao;
                    ow <= ow;
                    ccs <= ccs;
                    state <= state;
                    done <= 1;
                end
                E10: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar + 1;
                    aw <= aw;
                    ao <= ao;
                    ccs <= ccs;
                    ow <= ow;
                    state <= E11;
                    done <= done;
                end
                E11: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ao <= ao;
                    ccs <= ccs;
                    done <= done;
                    ow <= ow;
                    if (npv) begin
                        state <= E12;
                    end else begin
                        state <= E10;
                    end
                end
                E12: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar + 1;
                    aw <= aw;
                    ao <= ao;
                    ow <= ow;
                    ccs <= ccs;
                    state <= E13;
                    done <= done;
                end
                E13: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ao <= ao;
                    ow <= ow;
                    ccs <= ccs;
                    done <= done;
                    if (npv) begin
                        state <= E14;
                    end else begin
                        state <= E12;
                    end
                end
                E14: begin
                    w <= 1;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ao <= ao;
                    ow <= ow;
                    ccs <= ccs;
                    state <= E15;
                    done <= done;
                end
                E15: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ao <= ao;
                    ow <= ow;
                    ccs <= ccs;
                    state <= E15_PATCH;
                    done <= done;
                end
                E15_PATCH: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    aw <= aw + 1;
                    ao <= ao + 1;
                    ow <= ow;
                    ccs <= ccs;
                    state <= E16;
                    done <= done;
                end
                E16: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ccs <= ccs;
                    ow <= ow;
                    done <= done;
                    if (npv) begin
                        ao <= ao - 1;
                        state <= E17;
                    end else begin
                        ao <= ao;
                        state <= E15;
                    end
                end
                E17: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ao <= ao;
                    ow <= ow;
                    ccs <= ccs;
                    done <= done;
                    state <= E18;
                end
                E18: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    ow <= ow;
                    aw <= aw + 1;
                    ao <= ao + 1;
                    ccs <= ccs;
                    state <= E19;
                    done <= done;
                end
                E19: begin
                    w <= w;
                    rs_n <= rs_n;
                    s <= s;
                    ar <= ar;
                    aw <= aw;
                    ccs <= ccs;
                    done <= done;
                    if (npv) begin
                        ow <= 0;
                        state <= E8;
                    end else begin
                        ow <= ow;
                        state <= E18;
                    end
                end
                default: begin
                    rs_n <= rs_n;
                    ccs <= ccs;
                    aw <= aw;
                    ao <= ao;
                    ow <= ow;
                    ar <= ar;
                    w <= w;
                    state <= state;
                end
            endcase
        end
        
    end

endmodule