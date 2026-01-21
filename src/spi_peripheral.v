`default_nettype none

module spi_peripheral (
    input wire clk, sclk, COPI, cs, rst_n,

    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);

    // sample these every rising edge of clk
    reg SCLK_sync1;
    reg SCLK_sync2;
    reg SCLK_prev;
    reg COPI_sync1;
    reg COPI_sync2;
    reg cs_sync1;
    reg cs_sync2;
    reg cs_prev;

    reg [14:0] data;
    reg [4:0] current_bit_shift; //current bit when shifting
    reg data_ready; // Flag to indicate data is ready to latch

    wire cs_negedge;
    wire SCLK_posedge;

    assign cs_negedge = cs_prev && !cs_sync2;
    assign SCLK_posedge = !SCLK_prev && SCLK_sync2;


    // Process SPI protocol in the clk domain
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            
            en_reg_out_7_0 <= 8'b0;
            en_reg_out_15_8 <= 8'b0;
            en_reg_pwm_7_0 <= 8'b0;
            en_reg_pwm_15_8 <= 8'b0;
            pwm_duty_cycle <= 8'b0;

            SCLK_sync1 <= 0;
            SCLK_sync2 <= 0;
            SCLK_prev <= 0;
            COPI_sync1 <= 0;
            COPI_sync2 <= 0;
            cs_sync1 <= 1;
            cs_sync2 <= 1;
            cs_prev <= 1;
            
            data <= 15'b0;
            current_bit_shift <= 5'b0;
            data_ready <= 1'b0;
            
        end else begin

            // updates on clk posedge
            SCLK_sync1 <= sclk;
            SCLK_sync2 <= SCLK_sync1;
            SCLK_prev <= SCLK_sync2;

            COPI_sync1 <= COPI;
            COPI_sync2 <= COPI_sync1;

            cs_sync1 <= cs;
            cs_sync2 <= cs_sync1;
            cs_prev <= cs_sync2;

            // Latch data when data_ready flag is set (one cycle after all 16 bits received)
            if (data_ready) begin
                case (data[14:8])
                    7'h00 : en_reg_out_7_0 <= data[7:0];
                    7'h01 : en_reg_out_15_8 <= data[7:0];
                    7'h02 : en_reg_pwm_7_0 <= data[7:0];
                    7'h03 : en_reg_pwm_15_8 <= data[7:0];
                    7'h04 : pwm_duty_cycle <= data[7:0];
                    default: ;
                endcase
                data_ready <= 1'b0;
            end

            if (cs_negedge) begin // cs falling edge, begin data capture
                data <= 15'b0;
                current_bit_shift <= 5'b0;
                data_ready <= 1'b0;
            end else if (!cs_sync2 && SCLK_posedge) begin // Shift data on SCLK rising edge while CS is low
                data <= {data[13:0],COPI_sync2};
                if (current_bit_shift == 5'd14) begin
                    // Signal that data is ready to latch (will happen next cycle)
                    current_bit_shift <= 0; // reset for next transaction
                    data_ready <= 1'b1;
                end else begin
                    current_bit_shift <= current_bit_shift + 1'b1;
                end
            end
        end
    end

endmodule