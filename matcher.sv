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
    NF,
    F,
    ERR,
} matcher_state;

// working
module matcher#(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    input logic cs,
    input logic [DATA_WIDTH - 1: 0] val_vocab,
    input logic [DATA_WIDTH - 1: 0] val_input,
    input logic [ADDR_WIDTH - 1: 0] vocab_start_addr,
    input logic [ADDR_WIDTH - 1: 0] vocab_end_addr,
    input logic [ADDR_WIDTH - 1: 0] input_start_addr,
    output logic [ADDR_WIDTH - 1: 0] addr_v,
    output logic [ADDR_WIDTH - 1: 0] addr_i
);

    logic done;
    logic found;

    // logic [ADDR_WIDTH- 1: 0] start_addr = 0;
    // logic [ADDR_WIDTH: 0] end_addr = 5'b10000;

    matcher_state state;
    logic [ADDR_WIDTH - 1: 0] av;
    logic [ADDR_WIDTH - 1: 0] ai;

    logic vo;
    logic npv;
    logic npi;
    logic e;

    assign addr_v = av;
    assign addr_i = ai;

    assign e = (val_vocab === val_input);
    assign npv = (val_vocab === 0);
    assign npi = (val_input === 0);
    assign vo = (av === vocab_end_addr);

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            state <= 0;
            av <= vocab_start_addr;
            ai <= input_start_addr;
            done <= 0;
            found <= 0;
        end else begin
            case(state)
                E0: begin
                    av <= vocab_start_addr;
                    ai <= input_start_addr;
                    if(cs) begin
                        state <= 2'b01;
                    end else begin
                        state <= state;
                    end
                    done <= 0;
                    found <= 0;
                end
                E1: begin
                    av <= av;
                    ai <= ai;
                    found <= 0;
                    done <= 0;
                    if (vo) begin
                        state <= NF;
                    end else if (!vo & npv) begin
                        state <= E5;
                    end else if(!vo & !npv & npi) begin
                        state <= E3;
                    end else if(!vo & !npv & !npi & !e) begin
                        state <= E6;
                    end else if(vo & npv & npi & e) begin
                        state <= E2;
                    end else begin
                        state <= state;
                    end
                end
                E2: begin
                    av <= av + 1;
                    ai <= ai + 1;
                    found <= 0;
                    done <= 0;
                    state <= E1;
                end
                E3: begin
                    av <= av;
                    ai <= ai;
                    found <= 0;
                    done <= 0;
                    state <= E4;
                end
                E4: begin
                    av <= av;
                    ai <= ai;
                    found <= 0;
                    done <= 0;
                    if (vo & !e) begin
                        state <= NF;
                    end else if (!vo & !e) begin
                        state <= E6;
                    end else if (npv & npi & e) begin
                        state <= F;
                    end else if(!vo & (npv xor npi) & e) begin
                        state <= ERR;
                    end else if(!vo & !npv & !npi & e) begin
                        state <= E8;
                    end else if(vo & !npv & !npi & e) begin
                        state <= NF;
                    end else begin
                        state <= state;
                    end
                end
                E5: begin
                    av <= av + 1;
                    ai <= input_start_addr;
                    found <= 0;
                    done <= 0;
                    state <= E1;
                end
                E6: begin
                    av <= av;
                    ai <= input_start_addr;
                    found <= 0;
                    done <= 0;
                    state <= E7;
                end
                E7: begin
                    av <= av;
                    ai <= ai;
                    found <= 0;
                    done <= 0;
                    if(!npv) begin
                        state <= E6;
                    end else begin
                        state <= E1;
                    end
                end
                E8: begin
                    av <= av + 1;
                    ai <= ai + 1;
                    found <= 0;
                    done <= 0;
                    state <= E4;
                end
                NF: begin
                    av <= av;
                    ai <= ai;
                    found <= 0;
                    done <= 1;
                    state <= state;
                end
                F: begin
                    av <= av;
                    ai <= ai;
                    found <= 1;
                    done <= 1;
                    state <= state;
                end
                Err: begin
                    av <= av;
                    ai <= ai;
                    found <= 0;
                    done <= 0;
                    state <= state;
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