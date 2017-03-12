
// 
// Module: uart_rx 
// 
// Notes:
// - UART reciever module.
//

module uart_rx(
input  wire       clk          , // Top level system clock input.
input  wire       resetn       , // Asynchronous active low reset.
input  wire       uart_rxd     , // UART Recieve pin.
input  wire       uart_rx_en   , // Recieve enable
output wire       uart_rx_break, // Did we get a BREAK message?
output wire       uart_rx_valid, // Valid data recieved and available.
output wire [7:0] uart_rx_data   // The recieved data.
);

// --------------------------------------------------------------------------- 
// External parameters.
// 

//
// Input bit rate of the UART line.
parameter   BIT_RATE        = 9600;
localparam  BIT_P           = (1000000000/BIT_RATE);

//
// Clock frequency in hertz.
parameter   CLK_HZ          = 50000000;
localparam  CLK_P           = 1000000000/ CLK_HZ;

//
// Number of data bits recieved per UART packet.
parameter   PAYLOAD_BITS    = 8;

//
// Number of stop bits indicating the end of a packet.
parameter   STOP_BITS       = 1;

// --------------------------------------------------------------------------- 
// Internal parameters.
// 

//
// Size of the registers which store sample counts and bit durations.
localparam       COUNT_REG_LEN      = 16;

//
// Number of clock cycles per uart bit.
localparam       CYCLES_PER_BIT     = BIT_P / (CLK_P*2);

//
// Number of samples that must be a 1 for a bit to be considered a 1.
localparam       SAMPLES_THRESHOLD  = 3* CYCLES_PER_BIT / 4;

// --------------------------------------------------------------------------- 
// Internal registers.
// 

//
// Internally latched value of the uart_rxd line. Helps break long timing
// paths from input pins into the logic.
reg rxd_reg;

//
// Storage for the recieved serial data.
reg [PAYLOAD_BITS-1:0] recieved_data;

//
// Counter for the number of cycles over a packet bit.
reg [COUNT_REG_LEN-1:0] cycle_counter;

//
// Counter for the number of recieved bits of the packet.
reg [3:0] bit_counter;

//
// Counter for the number of samples of the input serial line that were a 1.
reg [COUNT_REG_LEN-1:0] one_counter;

//
// Current and next states of the internal FSM.
reg [2:0] fsm_state;
reg [2:0] n_fsm_state;

localparam FSM_IDLE = 0;
localparam FSM_START= 1;
localparam FSM_RECV = 2;
localparam FSM_STOP = 3;

// --------------------------------------------------------------------------- 
// Output assignment
// 

assign uart_rx_break = uart_rx_valid && ~|recieved_data;
assign uart_rx_valid = fsm_state == FSM_STOP && n_fsm_state == FSM_IDLE;
assign uart_rx_data  = recieved_data;

// --------------------------------------------------------------------------- 
// FSM next state selection.
// 

wire next_bit     = cycle_counter == CYCLES_PER_BIT;
wire payload_done = bit_counter == PAYLOAD_BITS;

//
// Handle picking the next state.
always @(*) begin : p_n_fsm_state
    case(fsm_state)
        FSM_IDLE : n_fsm_state = rxd_reg      ? FSM_IDLE : FSM_START;
        FSM_START: n_fsm_state = next_bit     ? FSM_RECV : FSM_START;
        FSM_RECV : n_fsm_state = payload_done ? FSM_STOP : FSM_RECV ;
        FSM_STOP : n_fsm_state = next_bit     ? FSM_IDLE : FSM_STOP ;
        default  : n_fsm_state = FSM_IDLE;
    endcase
end

// --------------------------------------------------------------------------- 
// Internal register setting and re-setting.
// 

//
// Handle updates to the recieved data register.
integer i = 0;
always @(posedge clk, negedge resetn) begin : p_recieved_data
    if(!resetn) begin
        recieved_data <= {PAYLOAD_BITS{1'b0}};
    end else if(fsm_state       == FSM_RECV       && next_bit ) begin
        recieved_data[PAYLOAD_BITS-1] <= one_counter > SAMPLES_THRESHOLD;
        for ( i = PAYLOAD_BITS-2; i >= 0; i = i - 1) begin
            recieved_data[i] <= recieved_data[i+1];
        end
    end
end

//
// Increments the bit counter when recieving.
always @(posedge clk, negedge resetn) begin : p_bit_counter
    if(!resetn) begin
        bit_counter <= 4'b0;
    end else if(fsm_state != FSM_RECV) begin
        bit_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(fsm_state == FSM_RECV && next_bit) begin
        bit_counter <= bit_counter + 1'b1;
    end
end


//
// Increments the sample counter when recieving. Used to see if the recieved
// bit was a zero or 1.
always @(posedge clk, negedge resetn) begin : p_one_counter
    if(!resetn) begin
        one_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(next_bit) begin
        one_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(fsm_state==FSM_RECV) begin
        one_counter <= one_counter + rxd_reg;
    end
end


//
// Increments the cycle counter when recieving.
always @(posedge clk, negedge resetn) begin : p_cycle_counter
    if(!resetn) begin
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(next_bit) begin
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(fsm_state == FSM_START || 
                fsm_state == FSM_RECV  || 
                fsm_state == FSM_STOP   ) begin
        cycle_counter <= cycle_counter + 1'b1;
    end
end


//
// Progresses the next FSM state.
always @(posedge clk, negedge resetn) begin : p_fsm_state
    if(!resetn) begin
        fsm_state <= FSM_IDLE;
    end else begin
        fsm_state <= n_fsm_state;
    end
end


//
// Responsible for updating the internal value of the rxd_reg.
always @(posedge clk, negedge resetn) begin : p_rxd_reg
    if(!resetn) begin
        rxd_reg <= 1'b1;
    end else if(uart_rx_en) begin
        rxd_reg <= uart_rxd;
    end
end


endmodule
