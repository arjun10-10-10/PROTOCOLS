module i2c_core (
    input wire clk,
    input wire rst_n,
    input wire [6:0] addr,
    input wire [7:0] data_in,
    output reg [7:0] data_out,
    input wire i2c_start,
    input wire i2c_rw,
    output reg ready,
    output reg scl_out,
    input wire sda_in,
    output reg sda_out,
    output reg sda_oe
);

    localparam IDLE       = 3'b000;
    localparam START      = 3'b001;
    localparam ADDRESS    = 3'b010;
    localparam ACK_BIT    = 3'b011;
    localparam WRITE_DATA = 3'b100;
    localparam READ_DATA  = 3'b101;
    localparam STOP       = 3'b110;

    reg [2:0] state, next_state;
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            bit_cnt <= 0;
            shift_reg <= 0;
            data_out <= 0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    if (i2c_start) begin
                        shift_reg <= {addr, i2c_rw};
                        bit_cnt <= 7;
                    end
                end
                START: bit_cnt <= 7;
                ADDRESS, WRITE_DATA: begin
                    if (bit_cnt == 0) bit_cnt <= 7;
                    else bit_cnt <= bit_cnt - 1;
                end
                ACK_BIT: begin
                    if (next_state == WRITE_DATA) shift_reg <= data_in;
                    bit_cnt <= 7;
                end
                READ_DATA: begin
                    data_out[bit_cnt] <= sda_in;
                    if (bit_cnt == 0) bit_cnt <= 7;
                    else bit_cnt <= bit_cnt - 1;
                end
            endcase
        end
    end

    always @(*) begin
        next_state = state;
        sda_out = 1'b1;
        sda_oe = 1'b1;
        scl_out = clk;
        ready = 1'b0;

        case (state)
            IDLE: begin
                ready = 1'b1;
                scl_out = 1'b1;
                if (i2c_start) next_state = START;
            end
            START: begin
                sda_out = 1'b0;
                scl_out = 1'b1;
                next_state = ADDRESS;
            end
            ADDRESS: begin
                sda_out = shift_reg[bit_cnt];
                if (bit_cnt == 0) next_state = ACK_BIT;
            end
            ACK_BIT: begin
                sda_oe = 1'b0; 
                if (shift_reg[0] == 1'b1) next_state = READ_DATA;
                else next_state = WRITE_DATA;
            end
            WRITE_DATA: begin
                sda_out = shift_reg[bit_cnt];
                if (bit_cnt == 0) next_state = STOP;
            end
            READ_DATA: begin
                sda_oe = 1'b0;
                if (bit_cnt == 0) next_state = STOP;
            end
            STOP: begin
                sda_out = 1'b0;
                scl_out = 1'b1;
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
endmodule
