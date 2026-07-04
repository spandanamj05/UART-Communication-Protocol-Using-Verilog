`timescale 1ns / 1ps

module uart_tx(
    input clk,
    input rst,
    input tx_start,
    input [7:0] tx_data,
    output reg tx,
    output reg tx_busy
);

parameter CLK_FREQ = 100000000;   // 100 MHz
parameter BAUD_RATE = 9600;

localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;

reg [13:0] baud_counter;
reg [3:0] bit_counter;
reg [9:0] shift_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        tx <= 1'b1;
        tx_busy <= 1'b0;
        baud_counter <= 0;
        bit_counter <= 0;
        shift_reg <= 10'b1111111111;
    end
    else begin
        if (!tx_busy) begin
            if (tx_start) begin
                tx_busy <= 1'b1;
                shift_reg <= {1'b1, tx_data, 1'b0}; // Stop, Data, Start
                baud_counter <= 0;
                bit_counter <= 0;
            end
        end
        else begin
            if (baud_counter < BAUD_DIV-1) begin
                baud_counter <= baud_counter + 1;
            end
            else begin
                baud_counter <= 0;

                tx <= shift_reg[0];
                shift_reg <= {1'b1, shift_reg[9:1]};

                if (bit_counter < 9) begin
                    bit_counter <= bit_counter + 1;
                end
                else begin
                    bit_counter <= 0;
                    tx_busy <= 0;
                    tx <= 1'b1;
                end
            end
        end
    end
end

endmodule
