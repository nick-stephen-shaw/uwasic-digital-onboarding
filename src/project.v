/*
 * Copyright (c) 2026 Nick Shaw
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_uwasic_onboarding_nick_shaw (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_oe,
    output wire [7:0] uio_out,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  wire [7:0]  en_reg_out_7_0;
  wire [7:0]  en_reg_out_15_8;
  wire [7:0]  en_reg_pwm_7_0;
  wire [7:0]  en_reg_pwm_15_8;
  wire [7:0]  pwm_duty_cycle;
  wire [15:0] pwm_out;

  spi_peripheral spi_inst (
      .clk(clk),
      .rst_n(rst_n),
      .sclk_in(ui_in[0]),
      .copi_in(ui_in[1]),
      .ncs_in(ui_in[2]),
      .en_reg_out_7_0(en_reg_out_7_0),
      .en_reg_out_15_8(en_reg_out_15_8),
      .en_reg_pwm_7_0(en_reg_pwm_7_0),
      .en_reg_pwm_15_8(en_reg_pwm_15_8),
      .pwm_duty_cycle(pwm_duty_cycle)
  );

  pwm_peripheral pwm_inst (
      .clk(clk),
      .rst_n(rst_n),
      .en_reg_out_7_0(en_reg_out_7_0),
      .en_reg_out_15_8(en_reg_out_15_8),
      .en_reg_pwm_7_0(en_reg_pwm_7_0),
      .en_reg_pwm_15_8(en_reg_pwm_15_8),
      .pwm_duty_cycle(pwm_duty_cycle),
      .out(pwm_out)
  );

  assign uo_out  = pwm_out[7:0];
  assign uio_out = pwm_out[15:8];
  assign uio_oe  = 8'hFF;

  wire _unused = &{ena, ui_in[7:3], uio_in, 1'b0};

endmodule