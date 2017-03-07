
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
output wire         uart_txd       // UART Transmit pin.
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

wire         tx_busy  ; // Module busy sending previous item.
wire         tx_enable; // Valid data recieved and available.
wire [7:0]   tx_data  ; // The recieved data.

// --------------------------------------------------------------------------- 
// Internal registers
// 

reg  [ 6:0] mem_access_count;   // Down counter for memory accesses.
reg  [ 7:0] mem_data;           // Data read or written from/to memory.
reg  [31:0] mem_access_addr;    // Address of the next memory read/write.

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
// Always enable the reciever.
assign rx_en = 1'b1;

//
// Enable sending of data out via the UART TX
assign tx_enable = fsm_state == FSM_RD_MEM_ACCESS_COUNT  ||
                   fsm_state == FSM_RD_MEM_ACCESS_ADDR_0 ||
                   fsm_state == FSM_RD_MEM_ACCESS_ADDR_1 ||
                   fsm_state == FSM_RD_MEM_ACCESS_ADDR_2 ||
                   fsm_state == FSM_RD_MEM_ACCESS_ADDR_3  ;

//
// What data do we send?
assign tx_data   = 
    {8{fsm_state == FSM_RD_MEM_ACCESS_COUNT }} & {1'b0,mem_access_count} |
    {8{fsm_state == FSM_RD_MEM_ACCESS_ADDR_3}} & mem_access_addr[31:24]  |
    {8{fsm_state == FSM_RD_MEM_ACCESS_ADDR_2}} & mem_access_addr[23:16]  |
    {8{fsm_state == FSM_RD_MEM_ACCESS_ADDR_1}} & mem_access_addr[15: 8]  |
    {8{fsm_state == FSM_RD_MEM_ACCESS_ADDR_0}} & mem_access_addr[ 7: 0]  ;


//
// Computes the next state of the control FSM.
//
always @(*) begin : p_uart_periph_next_state

    n_fsm_state = FSM_IDLE;

    case (fsm_state)
        
        FSM_IDLE: begin
            n_fsm_state = rx_valid ? FSM_DECODE_CMD : FSM_IDLE;
        end
        
        FSM_DECODE_CMD: begin
          case(rx_data)
            CMD_WR_MEM_ACCESS_COUNT : n_fsm_state = FSM_WR_MEM_ACCESS_COUNT ;
            CMD_RD_MEM_ACCESS_COUNT : n_fsm_state = FSM_RD_MEM_ACCESS_COUNT ;
            CMD_WR_MEM_ACCESS_ADDR_0: n_fsm_state = FSM_WR_MEM_ACCESS_ADDR_0;
            CMD_WR_MEM_ACCESS_ADDR_1: n_fsm_state = FSM_WR_MEM_ACCESS_ADDR_1;
            CMD_WR_MEM_ACCESS_ADDR_2: n_fsm_state = FSM_WR_MEM_ACCESS_ADDR_2;
            CMD_WR_MEM_ACCESS_ADDR_3: n_fsm_state = FSM_WR_MEM_ACCESS_ADDR_3;
            CMD_RD_MEM_ACCESS_ADDR_0: n_fsm_state = FSM_RD_MEM_ACCESS_ADDR_0;
            CMD_RD_MEM_ACCESS_ADDR_1: n_fsm_state = FSM_RD_MEM_ACCESS_ADDR_1;
            CMD_RD_MEM_ACCESS_ADDR_2: n_fsm_state = FSM_RD_MEM_ACCESS_ADDR_2;
            CMD_RD_MEM_ACCESS_ADDR_3: n_fsm_state = FSM_RD_MEM_ACCESS_ADDR_3;
            default                 : n_fsm_state = FSM_IDLE;
          endcase
        end
        
        FSM_RD_MEM_ACCESS_ADDR_0: begin 
            n_fsm_state = tx_busy ? FSM_RD_MEM_ACCESS_ADDR_0 : FSM_IDLE;
        end

        FSM_RD_MEM_ACCESS_ADDR_1: begin 
            n_fsm_state = tx_busy ? FSM_RD_MEM_ACCESS_ADDR_1 : FSM_IDLE;
        end

        FSM_RD_MEM_ACCESS_ADDR_2: begin 
            n_fsm_state = tx_busy ? FSM_RD_MEM_ACCESS_ADDR_2 : FSM_IDLE;
        end

        FSM_RD_MEM_ACCESS_ADDR_3: begin 
            n_fsm_state = tx_busy ? FSM_RD_MEM_ACCESS_ADDR_3 : FSM_IDLE;
        end

        FSM_RD_MEM_ACCESS_COUNT : begin 
            n_fsm_state = tx_busy ? FSM_RD_MEM_ACCESS_COUNT  : FSM_IDLE;
        end

        FSM_WR_MEM_ACCESS_ADDR_0: begin
            n_fsm_state = rx_valid ? FSM_IDLE : FSM_WR_MEM_ACCESS_ADDR_0;
        end

        FSM_WR_MEM_ACCESS_ADDR_1: begin
            n_fsm_state = rx_valid ? FSM_IDLE : FSM_WR_MEM_ACCESS_ADDR_1;
        end

        FSM_WR_MEM_ACCESS_ADDR_2: begin
            n_fsm_state = rx_valid ? FSM_IDLE : FSM_WR_MEM_ACCESS_ADDR_2;
        end

        FSM_WR_MEM_ACCESS_ADDR_3: begin
            n_fsm_state = rx_valid ? FSM_IDLE : FSM_WR_MEM_ACCESS_ADDR_3;
        end

        FSM_WR_MEM_ACCESS_COUNT : begin
            n_fsm_state = rx_valid ? FSM_IDLE : FSM_WR_MEM_ACCESS_COUNT;
        end

        default: begin
            n_fsm_state = FSM_IDLE;
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

//
// Updates the memory access address register.
always @(posedge clk, negedge resetn) begin : p_uart_mem_access_addr
    if(!resetn) begin
        mem_access_addr <= 32'b0;
    end else if (fsm_state == FSM_WR_MEM_ACCESS_ADDR_0 && rx_valid) begin
        mem_access_addr <= {mem_access_addr[31:24],
                            mem_access_addr[23:16],
                            mem_access_addr[15: 8],
                            rx_data               };
    end else if (fsm_state == FSM_WR_MEM_ACCESS_ADDR_1 && rx_valid) begin
        mem_access_addr <= {mem_access_addr[31:24],
                            mem_access_addr[23:16],
                            rx_data               ,
                            mem_access_addr[ 7: 0]};
    end else if (fsm_state == FSM_WR_MEM_ACCESS_ADDR_2 && rx_valid) begin
        mem_access_addr <= {mem_access_addr[31:24],
                            rx_data               ,
                            mem_access_addr[15: 8],
                            mem_access_addr[ 7: 0]};
    end else if (fsm_state == FSM_WR_MEM_ACCESS_ADDR_3 && rx_valid) begin
        mem_access_addr <= {rx_data               ,
                            mem_access_addr[23:16],
                            mem_access_addr[15: 8],
                            mem_access_addr[ 7: 0]};
    end
end

//
// Updates the memory access count register when needed.
always @(posedge clk, negedge resetn) begin : p_uart_mem_access_count
    if(!resetn) begin
        mem_access_count <= 7'b0;
    end else if (fsm_state == FSM_WR_MEM_ACCESS_COUNT && rx_valid) begin
        mem_access_count <= rx_data[6:0];
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
.CLK_HZ  (CLK_HZ  )
) i_uart_rx(
.clk       (clk       ) ,   // Top level system clock input.
.resetn    (resetn    ) ,   // Asynchronous active low reset.
.uart_rxd  (uart_rxd  ) ,   // UART Recieve pin.
.recv_en   (rx_en     ) ,   // Recieve enable
.break     (rx_break  ) ,   // Did we get a BREAK message?
.recv_valid(rx_valid  ) ,   // Valid data recieved and available.
.recv_data (rx_data   )     // The recieved data.
);


//
// UART Transmitter module.
//
uart_tx #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  )
) i_uart_tx(
.clk       (clk       ) ,   // Top level system clock input.
.resetn    (resetn    ) ,   // Asynchronous active low reset.
.uart_txd  (uart_txd  ) ,   // UART Recieve pin.
.tx_busy   (tx_busy   ) ,   // Module busy sending previous item.
.tx_enable (tx_enable ) ,   // Valid data recieved and available.
.tx_data   (tx_data   )     // The recieved data.
);

endmodule
