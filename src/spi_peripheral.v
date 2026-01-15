`default_nettype none

module spi_peripheral (
    input wire clk, sclk, COPI, cs, rst_n,

    output wire CIPO,
    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);

    // sample these every rising edge of clk
    reg [1:0] SCLK_sync;
    reg [1:0] COPI_sync;
    reg [1:0] cs_sync;

    reg [15:0] data;
    reg [4:0] current_bit_shift; //current bit when shifting

    // Process SPI protocol in the clk domain
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            
            en_reg_out_7_0 <= 8'b0;
            en_reg_out_15_8 <= 8'b0;
            en_reg_pwm_7_0 <= 8'b0;
            en_reg_pwm_15_8 <= 8'b0;
            pwm_duty_cycle <= 8'b0;

            SCLK_sync <= 2'b0;
            COPI_sync <= 2'b0;
            cs_sync <= 2'b0;
        end else begin

            // updates on clk posedge
            SCLK_sync <= {SCLK_sync[0], sclk};
            COPI_sync <= {COPI_sync[0], COPI};
            cs_sync <= {cs_sync[0], cs};
        end

        if (cs_sync == 2'b10) begin // cs falling edge, begin data capture
            data <= 16'b0;
            current_bit_shift <= 5'b0;
        end else if (cs_sync == 2'b00 && SCLK_sync == 2'b01 && current_bit_shift != 5'b10000) begin // sclk rising edge
            data[current_bit_shift] <= COPI_sync[1];
            current_bit_shift <= current_bit_shift + 1;
        end

        if (current_bit_shift == 5'b10000 && data[15] == 1) begin // finished shifting and write, write only once
            case (data[14:8])
                7'h00 : en_reg_out_7_0 <= data[7:0];
                7'h01 : en_reg_out_15_8 <= data[7:0];
                7'h02 : en_reg_pwm_7_0 <= data[7:0];
                7'h03 : en_reg_pwm_15_8 <= data[7:0];
                7'h04 : pwm_duty_cycle <= data[7:0];
                default: ;
            endcase
        end
    end

    assign CIPO = 1'b0;


endmodule