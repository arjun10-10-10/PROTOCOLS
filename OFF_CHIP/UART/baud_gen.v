module baud_rate_gen #(
    parameter CLK_FREQ = 50000000, // 50 MHz default clock
    parameter BAUD_RATE = 115200
)(
    input  wire clk,
    input  wire rst_n,
    output reg  tick
);
   
    local find_MAX = CLK_FREQ / (BAUD_RATE * 16);
    localparam WIDTH = $clog2(find_MAX);
    
    reg [WIDTH-1:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            tick    <= 0;
        end else if (counter == find_MAX - 1) begin
            counter <= 0;
            tick    <= 1;
        end else begin
            counter <= counter + 1;
            tick    <= 0;
        end
    end
endmodule
