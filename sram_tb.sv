`timescale 1ns / 1ps

module sram_tb();

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4;
    localparam CLK_PERIOD = 10;

    // Signals
    logic clk;
    logic rst_n;
    logic cs;
    logic we;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] din;
    logic [DATA_WIDTH-1:0] dout;

    // Instantiate the SRAM
    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("vocab.bin")
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .cs(cs),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Test stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        cs = 0;
        we = 0;
        addr = 0;
        din = 0;

        // Reset
        #(CLK_PERIOD*2) rst_n = 1;

        // Read initial values
        for (int i = 0; i < 2**ADDR_WIDTH; i++) begin
            @(posedge clk);
            cs = 1;
            we = 0;
            addr = i;
            @(posedge clk);
            $display("Address %0d: %h", i, dout);
        end

        // Write new values
        for (int i = 0; i < 2**ADDR_WIDTH; i++) begin
            @(posedge clk);
            cs = 1;
            we = 1;
            addr = i;
            din = $random;
            @(posedge clk);
        end

        // Read back written values
        for (int i = 0; i < 2**ADDR_WIDTH; i++) begin
            @(posedge clk);
            cs = 1;
            we = 0;
            addr = i;
            @(posedge clk);
            $display("Address %0d: %h", i, dout);
        end

        // Test complete
        $display("Test complete");
        $finish;
    end

endmodule