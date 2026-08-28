// SPI Peripheral:
// Receives 16-bit MSB-first writes and
// exposes five-bit configuration registers

`default_nettype none

module spi_peripheral(
    input wire clk,
    input wire rst_n,
    input wire sclk_in,
    input wire copi_in,
    input wire ncs_in,

    output reg [7:0] en_reg_out_7_0,
    output reg[7:0] en_reg_out_15_8,
    output reg[7:0] en_reg_pwm_7_0,
    output reg[7:0] en_reg_pwm_15_8
);
//Two flip-flop registers
reg [1:0] sclk_sync;
reg [1:0] copi_sync;
reg [1:0] ncs_sync;

reg sclk_prev;
reg ncs_prev;

always @(posedge clk) begin
    if (!rst_n) begin
        sclk_sync <= 2'b00;
        copi_sync <= 2'b00;
        ncs_sync <= 2'b11;

        sclk_prev <= 1'b0;
        ncs_prev <= 1'1;
    end else begin
        sclk_sync <= {sclk_sync[0], sclk_in};
        copi_sync <= {copi_sync[0], copi_in};
        ncs_sync <= {ncs_sync[0], ncs_in};

        sclk_prev <= sclk_sync[1];
        ncs_prev <= ncs_sync[1];
    end
end

wire sclk_rising = sclk_sync[1] & ~sclk_prev;
wire ncs_falling = ncs_sync[1] & ncs_prev;
wire ncs_rising = ncs_sync[1] & ~ncs_prev;