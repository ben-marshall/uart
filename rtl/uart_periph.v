
// 
// Module: uart_rx 
// 
//  UART peripheral module. Able to send and recieve bytes over UART.
//  Contains interfaces to allow internal register programming from other
//  modules in a system.
//

module uart_periph(
input  wire         clk        ,   // Top level system clock input.
input  wire         resetn     ,   // Asynchronous active low reset.

input  wire         uart_rxd   ,   // UART Recieve pin.
output wire         uart_txd   ,   // UART Transmit pin.
);

// --------------------------------------------------------------------------- 
// External parameters
// 

parameter   BIT_RATE = 9600;      // Input bit rate of the UART line.
parameter   CLK_HZ   = 100000000; // Clock frequency in hertz.


// --------------------------------------------------------------------------- 
// Internal parameters and constants
// 

localparam CMD_WR_MEM_ACCESS_COUNT  = 8'd1;
localparam CMD_RD_MEM_ACCESS_COUNT  = 8'd2;

localparam CMD_WR_MEM_ACCESS_ADDR_0 = 8'd3;
localparam CMD_WR_MEM_ACCESS_ADDR_1 = 8'd4;
localparam CMD_WR_MEM_ACCESS_ADDR_2 = 8'd5;
localparam CMD_WR_MEM_ACCESS_ADDR_3 = 8'd6;

localparam CMD_RD_MEM_ACCESS_ADDR_0 = 8'd7;
localparam CMD_RD_MEM_ACCESS_ADDR_1 = 8'd8;
localparam CMD_RD_MEM_ACCESS_ADDR_2 = 8'd9;
localparam CMD_RD_MEM_ACCESS_ADDR_3 = 8'd10;

localparam CMD_DO_MEM_WRITE         = 8'd11;
localparam CMD_DO_MEM_READ          = 8'd12;

wire         rx_en   ;  // Recieve enable
wire         rx_break;  // Did we get a BREAK message?
wire         rx_valid;  // Valid data recieved and available.
wire [7:0]   rx_data ;  // The recieved data.

// --------------------------------------------------------------------------- 
// Internal registers
// 

reg  [ 6:0] mem_access_count;   // Down counter for memory accesses.
reg  [ 7:0] mem_data;           // Data read or written from/to memory.
reg  [31:0] mem_access_addr;    // Address of the next memory read/write.
reg         mem_wr_en;          // Write or read a memory address?

// --------------------------------------------------------------------------- 
// Internal state machine processing.
// 

localparam FSM_IDLE                 = 5'd0;
localparam FSM_DECODE_CMD           = 5'd1;
localparam FSM_WR_MEM_ACCESS_COUNT  = 5'd2;
localparam FSM_RD_MEM_ACCESS_COUNT  = 5'd3;
localparam FSM_WR_MEM_ACCESS_ADDR_0 = 5'd4;
localparam FSM_WR_MEM_ACCESS_ADDR_1 = 5'd5;
localparam FSM_WR_MEM_ACCESS_ADDR_2 = 5'd6;
localparam FSM_WR_MEM_ACCESS_ADDR_3 = 5'd7;
localparam FSM_RD_MEM_ACCESS_ADDR_0 = 5'd8;
localparam FSM_RD_MEM_ACCESS_ADDR_1 = 5'd9;
localparam FSM_RD_MEM_ACCESS_ADDR_2 = 5'd10;
localparam FSM_RD_MEM_ACCESS_ADDR_3 = 5'd11;

reg  [4:0] fsm_state;
reg  [4:0] n_fsm_state;

//
// Computes the next state of the control FSM.
//
always @(*) begin : p_uart_periph_next_state

    n_fsm_state <= FSM_IDLE;

    case (fsm_state)
        
        FSM_IDLE: begin
            n_fsm_state <= rx_valid ? FSM_DECODE_CMD : FSM_IDLE;
        end
        
        FSM_DECODE_CMD: begin
          case(rx_data)
            CMD_WR_MEM_ACCESS_COUNT : n_fsm_state <= FSM_WR_MEM_ACCESS_COUNT ;
            CMD_RD_MEM_ACCESS_COUNT : n_fsm_state <= FSM_RD_MEM_ACCESS_COUNT ;
            CMD_WR_MEM_ACCESS_ADDR_0: n_fsm_state <= FSM_WR_MEM_ACCESS_ADDR_0;
            CMD_WR_MEM_ACCESS_ADDR_1: n_fsm_state <= FSM_WR_MEM_ACCESS_ADDR_1;
            CMD_WR_MEM_ACCESS_ADDR_2: n_fsm_state <= FSM_WR_MEM_ACCESS_ADDR_2;
            CMD_WR_MEM_ACCESS_ADDR_3: n_fsm_state <= FSM_WR_MEM_ACCESS_ADDR_3;
            CMD_RD_MEM_ACCESS_ADDR_0: n_fsm_state <= FSM_RD_MEM_ACCESS_ADDR_0;
            CMD_RD_MEM_ACCESS_ADDR_1: n_fsm_state <= FSM_RD_MEM_ACCESS_ADDR_1;
            CMD_RD_MEM_ACCESS_ADDR_2: n_fsm_state <= FSM_RD_MEM_ACCESS_ADDR_2;
            CMD_RD_MEM_ACCESS_ADDR_3: n_fsm_state <= FSM_RD_MEM_ACCESS_ADDR_3;
            default                 : n_fsm_state <= FSM_IDLE;
          endcase
        end

        default: begin
            n_fsm_state <= FSM_IDLE;
        end

    endcase

end


//
// Progress the main control / command FSM.
// 
always @(posedge clk, negedge resetn) begin : p_uart_periph_fsm_progress
    if(!resetn) begin
        fsm_state <= FSM_IDLE;
    end else begin
        fsm_state <= n_fsm_state;
    end
end

// --------------------------------------------------------------------------- 
// Sub-module instances.
// 

//
// UART Reciever module.
//
uart_rx #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  ),
) i_uart_rx(
.clk       (clk       ) ,   // Top level system clock input.
.resetn    (resetn    ) ,   // Asynchronous active low reset.
.uart_rxd  (uart_rxd  ) ,   // UART Recieve pin.
.recv_en   (rx_en     ) ,   // Recieve enable
.break     (rx_break  ) ,   // Did we get a BREAK message?
.recv_valid(rx_valid  ) ,   // Valid data recieved and available.
.recv_data (rx_data   )     // The recieved data.
);

endmodule
