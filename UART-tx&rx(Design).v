
//DESIGN
module uart_tx_rx(
    input clk,
    input [7:0] data_in,
    input rx,
    input tx_start,
    output reg tx = 1,
    output reg [7:0] data_out,
    output active
);
    parameter IDLE = 2'b00;
    parameter START = 2'b01;
    parameter DATA = 2'b10;
    parameter STOP = 2'b11;

    reg [1:0] tx_state = IDLE;
    reg [1:0] rx_state = IDLE;
    reg [12:0] tx_cnt = 0;
    reg [12:0] rx_cnt = 0;
    reg [2:0] tx_bit_index = 0;
    reg [2:0] rx_bit_index = 0;
    wire tx_en;
    wire rx_en;
    reg tx_busy = 0;
    reg rx_busy = 0;

    assign active = tx_busy || rx_busy;

    parameter clk_freq = 50000000;
    parameter baud_rate = 9600;
    parameter clk_per_bit = clk_freq/baud_rate;
    parameter clk_half_bit = clk_per_bit/2;

    always @(posedge clk) begin
        if (tx_busy==0)
            tx_cnt <= 0;
        else begin
            if(tx_cnt==clk_per_bit)
                tx_cnt <= 0;
            else
                tx_cnt <= tx_cnt + 1;
        end
    end

    always @(posedge clk) begin
        if (rx_busy==0 || (rx_state==START && rx_cnt==clk_half_bit))
            rx_cnt <= 0;
        else begin
            if (rx_cnt==clk_per_bit)
                rx_cnt <= 0;
            else
                rx_cnt <= rx_cnt + 1;
        end
    end

    assign tx_en = (tx_cnt==clk_per_bit-1);
    assign rx_en = (rx_cnt == clk_per_bit-1);

    always @(posedge clk) begin
        case (tx_state)
            IDLE: begin
                tx <= 1;
                tx_bit_index <= 0;

                if (tx_start) begin
                    tx_busy<=1;
                    tx_state<=START;
                end
            end

            START: begin
                tx<=0;
                if (tx_en) begin
                    tx_state<=DATA;
                end
            end

            DATA: begin
                tx <= data_in[tx_bit_index];
                if (tx_en) begin
                    if (tx_bit_index==7) begin
                        tx_bit_index <= 0;
                        tx_state <= STOP;
                    end
                    else
                        tx_bit_index <= tx_bit_index + 1;
                end
            end

            STOP: begin
                tx<=1;
                if (tx_en) begin
                    tx_busy <= 0;
                    tx_state <= IDLE;
                end
            end

        endcase
    end

    always @(posedge clk) begin
        case (rx_state) 
            IDLE: begin
                if (rx==0) begin
                    rx_busy <= 1;
                    rx_state <= START;
                end
            end

            START: begin
                if (rx_cnt==clk_half_bit) begin
                    rx_state <= DATA;
                end
            end

            DATA: begin
                if (rx_en) begin
                    data_out[rx_bit_index] <= rx;
                    if (rx_bit_index==7) begin
                        rx_bit_index <= 0;
                        rx_state <= STOP;
                    end
                    else
                        rx_bit_index <= rx_bit_index + 1;
                end
            end

            STOP: begin
                if (rx_en) begin
                    rx_busy <= 0;
                    rx_state <= IDLE;
                end
            end

        endcase
    end

endmodule
