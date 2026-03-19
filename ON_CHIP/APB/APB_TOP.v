module top_APB
#(parameter WIDTH=8, ADDR=4)
(
 input PCLK,
 input PRESETn,

 input transfer,
 input write,
 input [ADDR-1:0] addr_in,
 input [WIDTH-1:0] data_in,

 output [WIDTH-1:0] data_out_master
);

// Master signals
wire [ADDR-1:0] PADDR;
wire [WIDTH-1:0] PWDATA;
wire PWRITE, PENABLE, PSEL_master;

// Slave select
wire PSEL_S0, PSEL_S1, PSEL_S2;

// Slave outputs
wire [WIDTH-1:0] PRDATA_S0, PRDATA_S1, PRDATA_S2;
wire PREADY_S0, PREADY_S1, PREADY_S2;
wire PSLVERR_S0, PSLVERR_S1, PSLVERR_S2;

// MUX outputs to master
wire [WIDTH-1:0] PRDATA_master;
wire PREADY_master;
wire PSLVERR_master;


apb_master #(.WIDTH(WIDTH), .ADDR(ADDR)) master0 (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PREADY(PREADY_master),
    .PSLVERR(PSLVERR_master),  
    .PRDATA(PRDATA_master),
    .transfer(transfer),
    .write(write),
    .addr_in(addr_in),
    .data_in(data_in),
    .data_out(data_out_master),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PSEL(PSEL_master),
    .PENABLE(PENABLE)
);

// Decoder to seleect slave
assign PSEL_S0 = PSEL_master && (PADDR[3:2] == 2'b00);
assign PSEL_S1 = PSEL_master && (PADDR[3:2] == 2'b01);
assign PSEL_S2 = PSEL_master && (PADDR[3:2] == 2'b10);

// Slaves
slave_APB slave0 (.PCLK(PCLK), .PRESETn(PRESETn),
 .PSEL(PSEL_S0), .PENABLE(PENABLE), .PWRITE(PWRITE),
 .PADDR(PADDR), .PWDATA(PWDATA),
 .PRDATA(PRDATA_S0), .PREADY(PREADY_S0), .PSLVERR(PSLVERR_S0));

slave_APB slave1 (.PCLK(PCLK), .PRESETn(PRESETn),
 .PSEL(PSEL_S1), .PENABLE(PENABLE), .PWRITE(PWRITE),
 .PADDR(PADDR), .PWDATA(PWDATA),
 .PRDATA(PRDATA_S1), .PREADY(PREADY_S1), .PSLVERR(PSLVERR_S1));

slave_APB slave2 (.PCLK(PCLK), .PRESETn(PRESETn),
 .PSEL(PSEL_S2), .PENABLE(PENABLE), .PWRITE(PWRITE),
 .PADDR(PADDR), .PWDATA(PWDATA),
 .PRDATA(PRDATA_S2), .PREADY(PREADY_S2), .PSLVERR(PSLVERR_S2));


assign PRDATA_master  = (PSEL_S0) ? PRDATA_S0 :
                        (PSEL_S1) ? PRDATA_S1 :
                        (PSEL_S2) ? PRDATA_S2 : 0;

assign PREADY_master  = (PSEL_S0) ? PREADY_S0 :
                        (PSEL_S1) ? PREADY_S1 :
                        (PSEL_S2) ? PREADY_S2 : 1;

assign PSLVERR_master = (PSEL_S0) ? PSLVERR_S0 :
                        (PSEL_S1) ? PSLVERR_S1 :
                        (PSEL_S2) ? PSLVERR_S2 : 0;

endmodule
