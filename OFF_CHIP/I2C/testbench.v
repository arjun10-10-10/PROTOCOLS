module tb;

    reg clk;
    reg rst_n;
    reg [6:0] addr;
    reg [7:0] data_in;
    wire [7:0] data_out;
    reg i2c_start;
    reg i2c_rw;
    wire ready;

    wire sda;
    wire scl;

    pullup(sda);
    pullup(scl);

    i2c_top master_uut (
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out),
        .i2c_start(i2c_start),
        .i2c_rw(i2c_rw),
        .ready(ready),
        .sda(sda),
        .scl(scl)
    );

    i2c_slave #(.SLAVE_ADDR(7'h5A)) slave_uut (
        .rst_n(rst_n),
        .sda(sda),
        .scl(scl)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        addr = 0;
        data_in = 0;
        i2c_start = 0;
        i2c_rw = 0;

        #100;
        rst_n = 1;
        #200;

        addr = 7'h5A;
        data_in = 8'hBE;
        i2c_rw = 0;
        i2c_start = 1;
        #40;
        i2c_start = 0;

        wait(ready == 1);
        #2000;
        $finish;
    end

endmodule
