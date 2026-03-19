module slave_APB
#(parameter WIDTH=8, ADDR=4)
(
 input PCLK,
 input PRESETn,

 input PSEL,
 input PENABLE,
 input PWRITE,
 input [ADDR-1:0] PADDR,
 input [WIDTH-1:0] PWDATA,

 output reg [WIDTH-1:0] PRDATA,
 output reg PREADY,
 output reg PSLVERR
);

reg [WIDTH-1:0] mem [0:7];

always @(posedge PCLK or negedge PRESETn)
begin
 if(!PRESETn) begin
  PRDATA<=0; PREADY<=0; PSLVERR<=0;
 end
 else begin
  PREADY<=0; PSLVERR<=0;

  if(PSEL && PENABLE) begin
    PREADY<=1;

    if(PADDR > 7) begin
      PSLVERR<=1;   // ERROR
    end
    else begin
      if(PWRITE)
        mem[PADDR] <= PWDATA;
      else
        PRDATA <= mem[PADDR];
    end
  end
 end
end

endmodule
