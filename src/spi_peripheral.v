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
    output reg[7:0] en_reg_pwm_15_8,
    output reg[7:0] pwm_duty_cycle
);
//Two flip-flop registers
reg [1:0] sclk_sync;
reg [1:0] copi_sync;2
reg [1:0] ncs_sync;

reg sclk_prev;
reg ncs_prev;

always @(posedge clk) begin
    if (!rst_n) begin
        sclk_sync <= 2'b00;
        copi_sync <= 2'b00;
        ncs_sync <= 2'b11;

        sclk_prev <= 1'b0;
        ncs_prev <= 1'b1;
    end else begin
        sclk_sync <= {sclk_sync[0], sclk_in};
        copi_sync <= {copi_sync[0], copi_in};
        ncs_sync <= {ncs_sync[0], ncs_in};

        sclk_prev <= sclk_sync[1];
        ncs_prev <= ncs_sync[1];
    end
end

wire sclk_rising = sclk_sync[1] & ~sclk_prev;
wire ncs_falling = ~ncs_sync[1] & ncs_prev;
wire ncs_rising = ncs_sync[1] & ~ncs_prev;

// increment 2: receive the transaction 

reg [15:0] shift_reg;
reg [4:0]  bit_count;

always @(posedge clk) begin
    if (!rst_n) begin
        shift_reg <= 16'h0000;
        bit_count <= 5'd0;
    end else if (ncs_falling) begin
        // New transaction starting — discard anything left over.
        shift_reg <= 16'h0000;
        bit_count <= 5'd0;
    end else if (sclk_rising && !ncs_sync[1]) begin
        // A bit arrived. Shift it in at the bottom, MSB-first.
        shift_reg <= {shift_reg[14:0], copi_sync[1]};
        bit_count <= bit_count + 5'd1;
    end
    // No else: flip-flops hold their value. Correct in a clocked block.
end

// increment 3: validity check 

wire [6:0] rx_addr = shift_reg[14:8];   // 7-bit address field
wire [7:0] rx_data = shift_reg[7:0];    // 8-bit data field

// A write commits only if all three hold:
//   - the transaction just ended (nCS went high)
//   - exactly 16 bits arrived
//   - the R/W flag says write
wire transaction_valid = ncs_rising
                       & (bit_count == 5'd16)
                       & shift_reg[15];

// increment 4: address decode and register write 

always @(posedge clk) begin
    if (!rst_n) begin
        en_reg_out_7_0  <= 8'h00;
        en_reg_out_15_8 <= 8'h00;
        en_reg_pwm_7_0  <= 8'h00;
        en_reg_pwm_15_8 <= 8'h00;
        pwm_duty_cycle  <= 8'h00;
    end else if (transaction_valid) begin
        case (rx_addr)
            7'h00:   en_reg_out_7_0  <= rx_data;
            7'h01:   en_reg_out_15_8 <= rx_data;
            7'h02:   en_reg_pwm_7_0  <= rx_data;
            7'h03:   en_reg_pwm_15_8 <= rx_data;
            7'h04:   pwm_duty_cycle  <= rx_data;
            default: ;   // invalid address: write nothing, change nothing
        endcase
    end
end

endmodule