`default_nettype none

module spi_peripheral (
    input wire clk,
    input wire rst_n,
    input wire COPI,
    input wire nCS,
    input wire SCLK,

    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);

    reg sclk_sync1, sclk_sync2;
    reg copi_sync1, copi_sync2;
    reg ncs_sync1, ncs_sync2;

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            sclk_sync1 <= 1'b0;
            sclk_sync2 <= 1'b0;
            copi_sync1 <= 1'b0;
            copi_sync2 <= 1'b0;
            ncs_sync1 <= 1'b1;
            ncs_sync2 <= 1'b1;
        end else begin
            sclk_sync1 <= SCLK;
            sclk_sync2 <= sclk_sync1;
            copi_sync1 <= COPI;
            copi_sync2 <= copi_sync1;
            ncs_sync1 <= nCS;
            ncs_sync2 <= ncs_sync1;
        end
    end
        
    reg sclk_prev;
    reg ncs_prev;
    wire sclk_rise;
    wire ncs_rise;
    wire ncs_fall;

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            sclk_prev <= 1'b0;
            ncs_prev <= 1'b1;
        end else begin
            sclk_prev <= sclk_sync2;
            ncs_prev <= ncs_sync2;
        end
    end

    assign sclk_rise = sclk_sync2 && !sclk_prev;
    assign ncs_rise = ncs_sync2 && !ncs_prev;
    assign ncs_fall = !ncs_sync2 && ncs_prev;

    reg [15:0] shift_reg;
    reg [4:0] bit_count;
    reg transaction_ready;

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            shift_reg <= 16'b0;
            bit_count <= 5'b0;
            transaction_ready <= 1'b0;
        end else if (ncs_fall) begin
            shift_reg <= 16'b0;
            bit_count <= 5'b0;
            transaction_ready <= 1'b0;
        end else if (ncs_rise) begin
            transaction_ready <= (bit_count == 5'd16);
        end else if (!ncs_sync2 && sclk_rise) begin
            if (bit_count < 5'd16) begin
                shift_reg <= {shift_reg [14:0], copi_sync2};
                bit_count <= bit_count + 5'd1;
            end else begin
                bit_count <= 5'd17;
            end
        end
    end

    reg transaction_processed;

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            en_reg_out_7_0 <= 8'b0;
            en_reg_out_15_8 <= 8'b0;
            en_reg_pwm_15_8 <= 8'b0;
            en_reg_pwm_7_0 <= 8'b0;
            pwm_duty_cycle <= 8'b0;
            transaction_processed <= 1'b0;
        end else if (transaction_ready && !transaction_processed) begin
            if (shift_reg [15]) begin
                case (shift_reg [14:8])
                    7'h00: en_reg_out_7_0 <= shift_reg [7:0];
                    7'h01: en_reg_out_15_8 <= shift_reg [7:0];
                    7'h02: en_reg_pwm_7_0 <= shift_reg [7:0];
                    7'h03: en_reg_pwm_15_8 <= shift_reg [7:0];
                    7'h04: pwm_duty_cycle <= shift_reg [7:0];
                    default: begin
                    end
                endcase
            end
            transaction_processed <= 1'b1;
        end else if (!transaction_ready && transaction_processed) begin
            transaction_processed <= 1'b0;
        end
    end

endmodule
