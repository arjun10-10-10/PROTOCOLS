module tb;
  parameter WIDTH = 8;
    parameter ADDR  = 4;
  reg  PCLK;
 reg PRESETn;

 reg transfer;
 reg write;
  reg [ADDR-1:0] addr_in;
  reg [WIDTH-1:0] data_in;

  wire [WIDTH-1:0] data_out_master;
  
  
  top_APB dut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .transfer(transfer),
    .write(write),
    .addr_in(addr_in),
    .data_in(data_in),
    .data_out_master(data_out_master)
);

  
   always#5 PCLK=~PCLK;
  
  initial begin
    $dumpfile("apb.vcd");
    $dumpvars(0, tb);

    PCLK = 0;
    PRESETn = 0;
    transfer = 0;
    write = 0;
    addr_in = 0;
    data_in = 0;

    
    #20;
    PRESETn = 1;
     #10;
        transfer = 1;
        write = 1;            // WRITE operation
        addr_in = 4'd3;       // address = 3
        data_in = 8'h55;      // data to write

        #100;
        
        $display("Memory[3] = %h", dut.slave0.mem[3]);
$finish;
end

  
endmodule
