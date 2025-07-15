`timescale 1ns / 1ps

module LineBuf #(
    DATA_WIDTH = 8,
    LATENCY = 0
) (
    input   clk,
    input   rst_n,
    input   in_valid,
    input  [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out
);
    localparam ADDR_WIDTH = $clog2(LATENCY);
    
    logic [ADDR_WIDTH-1:0] addra = 0;
    logic [ADDR_WIDTH-1:0] addrb = 1;
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            addra <= 0;
            addrb <= 1;
        end 
        else if (in_valid) begin
            if (addra >= LATENCY - 1) begin
                addra <= 0;
            end else begin
                addra <= addra + 1;
            end

            if (addrb >= LATENCY - 1) begin
                addrb <= 0;
            end else begin
                addrb <= addrb + 1;
            end
        end
    end
    // 数据位宽一定要相等，深度可以开大一些
    BRAM_32x8192 bram_inst_linebuf (
        .clka(clk),    // input wire clka
        .wea(in_valid),      // input wire [0 : 0] wea
        .addra(addra),  // input wire [ADDR_WIDTH-1 : 0] addra
        .dina(data_in),    // input wire [DATA_WIDTH-1 : 0] dina
        .clkb(clk),    // input wire clkb
        .enb(1'b1),      // input wire enb
        .addrb(addrb),  // input wire [ADDR_WIDTH-1 : 0] addrb
        .doutb(data_out)  // output wire [DATA_WIDTH-1 : 0] doutb
    );

endmodule