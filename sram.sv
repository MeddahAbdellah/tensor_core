module sram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter INIT_FILE = "" // New parameter for initialization file
) (
    input logic clk,
    input logic cs,
    input logic we,
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
);

    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:2**ADDR_WIDTH-1];

    // Initialization
    initial begin
        if (INIT_FILE != "") begin
            $readmemb(INIT_FILE, mem);
        end else begin
            for (int i = 0; i < 2**ADDR_WIDTH; i++) begin
                mem[i] = 1'b1;
            end
        end
    end

    // Read operation
    always_ff @(posedge clk) begin
        if (cs && !we) begin
            dout <= mem[addr];
        end
    end

    // Write operation
    always_ff @(posedge clk) begin
        if (cs && we) begin
            mem[addr] <= din;
        end
    end

endmodule