module apb_master
#(parameter WIDTH = 8, ADDR = 8)
(
    input PCLK,
    input PRESETn,

    // Control inputs
    input transfer,
    input write,
    input [ADDR-1:0] addr_in,
    input [WIDTH-1:0] data_in,

   // Outputs 
    output reg [WIDTH-1:0] data_out,
    output reg done,
    output reg error,

    // Slave signals
    input PREADY,
    input PSLVERR,
    input [WIDTH-1:0] PRDATA,

    // APB outputs
    output reg PSEL,
    output reg PENABLE,
    output reg PWRITE,
    output reg [ADDR-1:0] PADDR,
    output reg [WIDTH-1:0] PWDATA   
);

    
    parameter IDLE   = 2'b00, SETUP  = 2'b01, ACCESS = 2'b10;
    reg [1:0] state, next_state;

    // state logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            state <= IDLE;
        else
            state <= next_state;
    end

    // next state logic
    always @(*) begin
        case (state)
          IDLE: begin
                if (transfer) next_state = SETUP;
                else next_state = IDLE;
                end
          SETUP:  next_state = ACCESS;
          ACCESS: begin
                   if (PREADY) begin
                               if (transfer)
                               next_state = SETUP;  
                               else
                               next_state = IDLE;
                              end
                   else
                   next_state = ACCESS;  // wait state
                   end

            default: next_state = IDLE;
            endcase
     end

    //output logic
    always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        PSEL     <= 0;
        PENABLE  <= 0;
        PWRITE   <= 0;
        PADDR    <= 0;
        PWDATA   <= 0;

        data_out <= 0;
        done     <= 0;
        error    <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                PSEL    <= 0;
                PENABLE <= 0;
                PWRITE  <= 0;
                done    <= 0;
                error   <= 0;
            end

            SETUP: begin
                PSEL    <= 1;
                PENABLE <= 0;
                PWRITE  <= write;
                PADDR   <= addr_in;
                PWDATA  <= (write) ? data_in : 0;
                done    <= 0;
            end

            ACCESS: begin
                PSEL    <= 1;
                PENABLE <= 1;
                if (PREADY) begin
                    done <= 1;
                    error <= PSLVERR;
                    if (!PWRITE)
                        data_out <= PRDATA;
                end else begin
                    done  <= 0;
                    error <= 0;
                end
            end

            default: begin
                PSEL    <= 0;
                PENABLE <= 0;
                PWRITE  <= 0;
                done    <= 0;
                error   <= 0;
            end
        endcase
  
        end//else end
    end //output logic always end
endmodule
