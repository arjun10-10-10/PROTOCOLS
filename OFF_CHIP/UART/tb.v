module uart_tb;

    parameter CLK_FREQ  = 50000000;
    parameter BAUD_RATE = 115200;
    parameter CLK_PERIOD = 20;

    reg        clk;
    reg        rst_n;
    reg        tx_start;
    reg  [7:0] tx_data;
    wire       tx;
    wire       tx_done;
    wire       rx_done;
    wire [7:0] rx_data;

    uart_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_done(tx_done),
        .rx(tx),
        .rx_done(rx_done),
        .rx_data(rx_data)
    );

    always begin
        #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        clk      = 0;
        rst_n    = 0;
        tx_start = 0;
        tx_data  = 8'h00;

        #100;
        rst_n = 1;
        #40;
        
        tx_data  = 8'hA5;
        tx_start = 1;
        #(CLK_PERIOD);
        tx_start = 0;

        @(posedge tx_done);
        @(posedge rx_done);

        #2000;
        tx_data  = 8'h5A;
        tx_start = 1;
        #(CLK_PERIOD);
        tx_start = 0;

        @(posedge rx_done);

        #5000;
        $finish;
    end

    initial begin
        $dumpfile("uart_sim.vcd");
        $dumpvars(0, uart_tb);
    end

endmodule
