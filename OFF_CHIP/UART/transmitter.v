module uart_tx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire       tick,      // 16x baud tick
    input  wire [7:0] tx_data,
    output reg        tx,
    output reg        tx_done
);
    localparam [1:0] IDLE  = 2'b00,
                     START = 2'b01,
                     DATA  = 2'b10,
                     STOP  = 2'b11;

    reg [1:0] state, next_state;
    reg [3:0] tick_count, tick_count_next;
    reg [2:0] bit_count, bit_count_next;
    reg [7:0] tx_data_reg, tx_data_next;
    reg       tx_next;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            tick_count <= 0;
            bit_count  <= 0;
            tx_data_reg<= 0;
            tx         <= 1'b1;
        end else begin
            state      <= next_state;
            tick_count <= tick_count_next;
            bit_count  <= bit_count_next;
            tx_data_reg<= tx_data_next;
            tx         <= tx_next;
        end
    end

    always @(*) begin
        next_state      = state;
        tick_count_next = tick_count;
        bit_count_next  = bit_count;
        tx_data_next    = tx_data_reg;
        tx_next         = tx;
        tx_done         = 1'b0;

        case (state)
            IDLE: begin
                tx_next = 1'b1;
                if (tx_start) begin
                    tx_data_next    = tx_data;
                    tick_count_next = 0;
                    next_state      = START;
                end
            end
            
            START: begin
                tx_next = 1'b0; // Start bit is low
                if (tick) begin
                    if (tick_count == 15) begin
                        tick_count_next = 0;
                        bit_count_next  = 0;
                        next_state      = DATA;
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
            
            DATA: begin
                tx_next = tx_data_reg[0];
                if (tick) begin
                    if (tick_count == 15) begin
                        tick_count_next = 0;
                        tx_data_next    = tx_data_reg >> 1;
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
                tx_next = 1'b1; // Stop bit is high
                if (tick) begin
                    if (tick_count == 15) begin
                        tx_done    = 1'b1;
                        next_state = IDLE;
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
        endcase
    end
endmodule
