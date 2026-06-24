module uart_top #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,
    
    // TX Interface
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx,
    output wire       tx_done,
    
    // RX Interface
    input  wire       rx,
    output wire       rx_done,
    output wire [7:0] rx_data
);

    wire baud_tick;

    // Instantiate Baud Rate Generator
    baud_rate_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) baud_gen_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tick(baud_tick)
    );

    // Instantiate Transmitter
    uart_tx tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tick(baud_tick),
        .tx_data(tx_data),
        .tx(tx),
        .tx_done(tx_done)
    );

    // Instantiate Receiver
    uart_rx rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .tick(baud_tick),
        .rx_done(rx_done),
        .rx_data(rx_data)
    );

endmodule
