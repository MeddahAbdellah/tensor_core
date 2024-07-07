module char_incr#(
    ADDR_WIDTH = 4
)(
    input logic clk,
    input logic rst_n,
    input logic cs,
    input logic [ADDR_WIDTH-1: 0] start_addr,
    input logic [ADDR_WIDTH-1: 0] end_addr,
    output logic [ADDR_WIDTH-1: 0] curr_addr,
    output logic overflow
);

    always_ff @(posedge clk or negedge rst_n) begin
        if(rst_n == 0) begin
            curr_addr <= start_addr;
            overflow <= 0;
        end else if(curr_addr == end_addr) begin
            curr_addr <= curr_addr;
            overflow <= 1;
        end else if(cs) begin
            curr_addr <= curr_addr + 1;
            overflow <= overflow;
        end else begin 
            curr_addr <= curr_addr;
            overflow <= overflow;
        end
    end

endmodule