typedef enum logic [3:0] {
    E0,
    E1,
    E2,
    E3,
    E4,
    E5,
    E6,
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
    encoder_state state;
    logic [ADDR_WIDTH - 1: 0] av;
    logic [ADDR_WIDTH - 1: 0] ao;
    logic [ADDR_WIDTH - 1: 0] ac;
    logic [ADDR_WIDTH - 1: 0] ao_current_char;
    logic [ADDR_WIDTH - 1: 0] a_output_code;


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
        .addr(grouper.done ? av : grouper.matcher.addr_v)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("C:\\Users\\abdal\\verilog_work\\tensor_core\\codes.bin")
    ) code_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b0),
        .addr(ac)
    );

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) output_code_ram (
        .clk(clk),
        .cs(1'b1),
        .we(1'b1),
        .addr(a_output_code),
        .din(code_ram.dout)
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
        .addr(grouper.done ? ao : grouper.ao)
    );

    assign e = vocab_ram.dout === output_ram.dout;
    assign npv = vocab_ram.dout === 0;
    assign npo = output_ram.dout === 0;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= E0;
            av <= 0;
            ao <= 0;
            ac <= 0;
            ao_current_char <= 0;
            a_output_code <= 0;
            done <= 0;
        end else begin
        case(state)
            E0: begin
                if(cs) begin
                    state <= E1;
                end else begin
                    state <= state;
                end
            end
            E1: begin
                if(grouper.done) begin
                    state <= E2;
                end else begin
                    state <= state;
                end
            end
            E2: begin
                av <= av + 1;
                ao <= ao + 1;
                ac <= ac;
                ao_current_char <= ao_current_char;
                a_output_code <= a_output_code;
                state <= E3;
            end
            E3: begin
                if(!e) begin
                    ao <= ao_current_char;
                    ac <= ac + 1;
                    state <= E4;
                end else if(e & !npv & !npo) begin
                    ao <= ao;
                    ac <= ac;
                    state <= E2;
                end else begin
                    ao_current_char <= ao;
                    ac <= ac;
                    state <= E5;
                end
            end
            E4: begin
                state <= E2;
            end
            E5: begin
                a_output_code <= a_output_code + 1;
                state <= E6;
            end
            E6: begin
                if(npo) begin
                    done <= 1;
                    state <= DONE;
                end else begin
                    state <= E2;
                end
            end
            DONE: begin
                done <= 1;
                state <= state;
            end
            default: begin
                av <= av;
                ao <= ao;
                ac <= ac;
                ao_current_char <= ao_current_char;
                a_output_code <= a_output_code;
                done <= done;
                state <= state;
            end
        endcase
        end
    end
endmodule