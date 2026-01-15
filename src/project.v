/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module tt_um_uwasic_onboarding_Hugh_Ding (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // IO direction
    // uio[0] = CIPO (output)
    // uio[1] = unused
    // uio[7:2] = PWM outputs
    assign uio_oe = 8'b11111101;

    // Unused inputs
    wire _unused = &{ena, uio_in};

    // Internal wires
    wire [7:0] en_reg_out_7_0;
    wire [7:0] en_reg_out_15_8;
    wire [7:0] en_reg_pwm_7_0;
    wire [7:0] en_reg_pwm_15_8;
    wire [7:0] pwm_duty_cycle;

    // PWM peripheral (SOLE driver of outputs)
    pwm_peripheral pwm_peripheral_instance (
        .clk(clk),
        .rst_n(rst_n),
        .en_reg_out_7_0(en_reg_out_7_0),
        .en_reg_out_15_8(en_reg_out_15_8),
        .en_reg_pwm_7_0(en_reg_pwm_7_0),
        .en_reg_pwm_15_8(en_reg_pwm_15_8),
        .pwm_duty_cycle(pwm_duty_cycle),
        .out({uio_out[7:2], uo_out})
    );

    // SPI peripheral
    spi_peripheral spi_peripheral_instance (
        .clk(clk),
        .sclk(ui_in[0]),
        .COPI(ui_in[1]),
        .cs(ui_in[2]),
        .rst_n(rst_n),
        .en_reg_out_7_0(en_reg_out_7_0),
        .en_reg_out_15_8(en_reg_out_15_8),
        .en_reg_pwm_7_0(en_reg_pwm_7_0),
        .en_reg_pwm_15_8(en_reg_pwm_15_8),
        .pwm_duty_cycle(pwm_duty_cycle)
    );


endmodule