module uart_rx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,
    input  wire       tick,     // 16x baud tick
    output reg        rx_done,
    output reg  [7:0] rx_data
);
    localparam [1:0] IDLE  = 2'b00,
                     START = 2'b01,
                     DATA  = 2'b10,
                     STOP  = 2'b11;

    reg [1:0] state, next_state;
    reg [3:0] tick_count, tick_count_next;
    reg [2:0] bit_count, bit_count_next;
    reg [7:0] rx_data_reg, rx_data_next;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            tick_count  <= 0;
            bit_count   <= 0;
            rx_data_reg <= 0;
            rx_data     <= 0;
        end else begin
            state       <= next_state;
            tick_count  <= tick_count_next;
            bit_count   <= bit_count_next;
            rx_data_reg <= rx_data_next;
            if (rx_done) rx_data <= rx_data_next;
        end
    end

    always @(*) begin
        next_state      = state;
        tick_count_next = tick_count;
        bit_count_next  = bit_count;
        rx_data_next    = rx_data_reg;
        rx_done         = 1'b0;

        case (state)
            IDLE: begin
                if (~rx) begin // Falling edge detected
                    tick_count_next = 0;
                    next_state      = START;
                end
            end
            
            START: begin
                if (tick) begin
                    if (tick_count == 7) begin // Center of start bit
                        tick_count_next = 0;
                        bit_count_next  = 0;
                        next_state      = DATA;
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
            
            DATA: begin
                if (tick) begin
                    if (tick_count == 15) begin // Center of data bit
                        tick_count_next = 0;
                        rx_data_next    = {rx, rx_data_reg[7:1]}; // Shift in MSB
                        if (bit_count == 7) begin
                            next_state = STOP;
                        end else begin
                            bit_count_next = bit_count + 1;
                        end
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
            
            STOP: begin
                if (tick) begin
                    if (tick_count == 15) begin // Center of stop bit
                        rx_done    = 1'b1;
                        next_state = IDLE;
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
        endcase
    end
endmodule
