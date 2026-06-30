module i2c_slave #(
    parameter SLAVE_ADDR = 7'h5A
)(
    input wire rst_n,
    inout wire sda,
    input wire scl
);

    localparam S_IDLE      = 2'b00;
    localparam S_ADDR      = 2'b01;
    localparam S_ACK       = 2'b10;
    localparam S_DATA      = 2'b11;

    reg [1:0] state;
    reg [3:0] bit_cnt;
    reg [7:0] rx_shift;
    reg [7:0] internal_reg;
    reg sda_out;
    reg sda_oe;

    assign sda = (sda_oe) ? sda_out : 1'bz;

    always @(negedge sda or negedge rst_n) begin
        if (!rst_n) begin
            if (scl) state <= S_IDLE;
        end
    end

    always @(posedge scl or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            bit_cnt <= 0;
            rx_shift <= 0;
            internal_reg <= 8'h00;
            sda_out <= 1'b1;
            sda_oe <= 1'b0;
        end else begin
            case (state)
                S_IDLE: begin
                    sda_oe <= 1'b0;
                    if (!sda) begin
                        state <= S_ADDR;
                        bit_cnt <= 0;
                    end
                end

                S_ADDR: begin
                    rx_shift <= {rx_shift[6:0], sda};
                    if (bit_cnt == 7) begin
                        if (rx_shift[7:1] == SLAVE_ADDR) begin
                            state <= S_ACK;
                        end else begin
                            state <= S_IDLE;
                        end
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                S_ACK: begin
                    sda_out <= 1'b0;
                    sda_oe <= 1'b1;
                    bit_cnt <= 0;
                    state <= S_DATA;
                end

                S_DATA: begin
                    sda_oe <= 1'b0;
                    rx_shift <= {rx_shift[6:0], sda};
                    if (bit_cnt == 7) begin
                        internal_reg <= {rx_shift[6:0], sda};
                        state <= S_IDLE;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
            endcase
        end
    end
endmodule
