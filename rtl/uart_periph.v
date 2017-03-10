
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

output wire [7:0]   uart_dbg   ,
input  wire         uart_rxd   ,   // UART Recieve pin.
output wire         uart_txd       // UART Transmit pin.
);

// --------------------------------------------------------------------------- 
// External parameters
// 

parameter   BIT_RATE = 9600;      // Input bit rate of the UART line.
parameter   CLK_HZ   = 100000000; // Clock frequency in hertz.

//
// FSM States
parameter   FSM_IDLE    =   0;
parameter   FSM_WRITE   =   1;
parameter   FSM_READ    =   2;

// --------------------------------------------------------------------------- 
// Internal parameters and constants
// 

wire         rx_en=1 ;  // Recieve enable
wire         rx_break;  // Did we get a BREAK message?
wire         rx_valid;  // Valid data recieved and available.
wire [7:0]   rx_data ;  // The recieved data.
wire [2:0]   rx_cmd = rx_data[7:5];
wire [4:0]   rx_arg = rx_data[4:0];

wire         tx_busy  ; // Module busy sending previous item.
wire         tx_enable; // Valid data recieved and available.
wire [7:0]   tx_data  ; // The recieved data.

// --------------------------------------------------------------------------- 
// Internal registers
// 

reg [7:0] reg_bank [0:7]; // General register bank.

reg [3:0] reg_addr      ; // Register being read / written.
reg [3:0] n_reg_addr    ; 

reg [1:0] fsm_state     ; // Current FSM state
reg [1:0] n_fsm_state   ; // Next FSM state.

// --------------------------------------------------------------------------- 
// Internal state machine processing.
// 

assign tx_enable = !tx_busy && fsm_state == FSM_READ;
assign tx_data   = reg_bank[reg_addr];

always @(*) begin: p_n_fsm_state
    n_fsm_state = FSM_IDLE;
    n_reg_addr  = 4'b0000;

    case(fsm_state)
        
        FSM_IDLE: begin
            if(rx_valid) begin
                n_reg_addr = rx_arg[3:0];
                if(rx_cmd == 3'b010) begin
                    n_fsm_state <= FSM_WRITE;
                end else if (rx_cmd == 3'b011) begin
                    n_fsm_state <= FSM_READ;
                end
            end
        end

        FSM_WRITE: begin
            n_fsm_state = rx_valid ? FSM_IDLE : FSM_WRITE;
        end

        FSM_READ: begin
            n_fsm_state = tx_busy ? FSM_READ : FSM_IDLE;
        end

        default: begin
            n_fsm_state <= FSM_IDLE;
        end

    endcase

end

//
// Progress the register address to the next value.
always @(posedge clk, negedge resetn) begin : p_reg_addr
    if(!resetn) begin
        reg_addr <= 4'b0;
    end else if(fsm_state == FSM_IDLE) begin
        reg_addr <= n_reg_addr;
    end
end

//
// Progress the control FSM to the next state.
always @(posedge clk, negedge resetn) begin : p_fsm_state
    if(!resetn) begin
        fsm_state <= FSM_IDLE;
    end else begin
        fsm_state <= n_fsm_state;
    end
end

//
// Read and write the register bank.
genvar i;
generate for (i=0; i <8; i = i + 1) begin
wire [7:0] reg_value = reg_bank[i];
    always @(posedge clk, negedge resetn) begin : p_reg_bank
        if(!resetn) begin
            reg_bank[i] <= 8'b0;
        end else if (i         == reg_addr  && 
                     fsm_state == FSM_WRITE && 
                     rx_valid   ) begin
            reg_bank[i] <= rx_data;
        end
    end
end endgenerate

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
