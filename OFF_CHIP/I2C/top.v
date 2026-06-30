module i2c_top (
    input wire clk,
    input wire rst_n,
    input wire [6:0] addr,
    input wire [7:0] data_in,
    output wire [7:0] data_out,
    input wire i2c_start,
    input wire i2c_rw,
    output wire ready,
    inout wire sda,
    inout wire scl
);

    wire i2c_clk;
    wire scl_out;
    wire sda_out;
    wire sda_in;
    wire sda_oe;

    clk_div #(.DIV_VAL(250)) clock_generator (
        .clk(clk),
        .rst_n(rst_n),
        .clk_out(i2c_clk)
    );

    i2c_core controller_core (
        .clk(i2c_clk),
        .rst_n(rst_n),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out),
        .i2c_start(i2c_start),
        .i2c_rw(i2c_rw),
        .ready(ready),
        .scl_out(scl_out),
        .sda_in(sda_in),
        .sda_out(sda_out),
        .sda_oe(sda_oe)
    );

    assign sda = (sda_oe) ? sda_out : 1'bz;
    assign sda_in = sda;
    assign scl = scl_out;

endmodule
