

// 
// Module: uart_tx 
// 
// Notes:
// - UART transmitter module.
//

module uart_tx(
input  wire         clk        ,   // Top level system clock input.
input  wire         resetn     ,   // Asynchronous active low reset.

output reg          uart_txd   ,   // UART transmit pin.

output wire         tx_busy    ,   // Module busy sending previous item.
input  wire         tx_enable  ,   // Valid data recieved and available.
input  wire [7:0]   tx_data        // The recieved data.
);

parameter   BIT_RATE = 9600;      // Input bit rate of the UART line.
parameter   CLK_HZ   = 100000000; // Clock frequency in hertz.

localparam [7:0] SAMPLES_PER_BIT   = CLK_HZ / BIT_RATE;
 
//
// Control FSM State encodings.
localparam FSM_WAIT  = 4'b1100;
localparam FSM_START = 4'b0000;
localparam FSM_BIT_0 = 4'b0001;
localparam FSM_BIT_1 = 4'b0010;
localparam FSM_BIT_2 = 4'b0011;
localparam FSM_BIT_3 = 4'b0100;
localparam FSM_BIT_4 = 4'b0101;
localparam FSM_BIT_5 = 4'b0110;
localparam FSM_BIT_6 = 4'b0111;
localparam FSM_BIT_7 = 4'b1000;
localparam FSM_STOP  = 4'b1001;

//
// Counter to tell how long to assert each tx line state for.
reg [7:0] sample_counter;

// Enable the sample counter.
wire      counter_en;
wire      counter_rst;

//
// Registered version of the data to be sent.
reg [7:0] tx_data_reg;

//
// Current and next states for the FSM.
reg [3:0] tx_state;
reg [3:0] n_tx_state;

//
// Tell other modules when we are busy sending stuff.
assign tx_busy = tx_state != FSM_WAIT;

//
// When should we enable or reset the sample counter?
assign counter_en   = tx_state != FSM_WAIT;
assign counter_rst  = tx_state != n_tx_state;

//
// Compute the next state of the transmitter FSM
always @(*) begin : p_tx_next_state
    n_tx_state = FSM_START;

    case(tx_state)
        FSM_WAIT: begin
            if(tx_enable) begin
                n_tx_state = FSM_START;
            end else begin
                n_tx_state = FSM_WAIT;
            end
        end
        FSM_START: begin
            if(sample_counter == SAMPLES_PER_BIT) begin
                n_tx_state = FSM_BIT_0;
            end else begin
                n_tx_state = FSM_START;
            end
        end
        FSM_BIT_0: begin
            n_tx_state = sample_counter == SAMPLES_PER_BIT ? FSM_BIT_1
                                                           : FSM_BIT_0;
        end
        FSM_BIT_1: begin
            n_tx_state = sample_counter == SAMPLES_PER_BIT ? FSM_BIT_2
                                                           : FSM_BIT_1;
        end
        FSM_BIT_2: begin
            n_tx_state = sample_counter == SAMPLES_PER_BIT ? FSM_BIT_3
                                                           : FSM_BIT_2;
        end
        FSM_BIT_3: begin
            n_tx_state = sample_counter == SAMPLES_PER_BIT ? FSM_BIT_4
                                                           : FSM_BIT_3;
        end
        FSM_BIT_4: begin
            n_tx_state = sample_counter == SAMPLES_PER_BIT ? FSM_BIT_5
                                                           : FSM_BIT_4;
        end
        FSM_BIT_5: begin
            n_tx_state = sample_counter == SAMPLES_PER_BIT ? FSM_BIT_6
                                                           : FSM_BIT_5;
        end
        FSM_BIT_6: begin
            n_tx_state = sample_counter == SAMPLES_PER_BIT ? FSM_BIT_7
                                                           : FSM_BIT_6;
        end
        FSM_BIT_7: begin
            n_tx_state = sample_counter == SAMPLES_PER_BIT ? FSM_STOP
                                                           : FSM_BIT_7;
        end
        FSM_STOP : begin
            n_tx_state = sample_counter == SAMPLES_PER_BIT ? FSM_WAIT 
                                                           : FSM_STOP ;
        end
        default: 
            n_tx_state = FSM_WAIT;
    endcase

end

//
// Capture the tx_data inputs when told to.
always @(posedge clk, negedge resetn) begin : p_tx_data_capture
    if(!resetn) begin
        tx_data_reg <= 8'b0;
    end else if(tx_enable && !tx_busy) begin
        tx_data_reg <= tx_data;
    end
end

//
// Progress the current state of the transmitter FSM.
always @(posedge clk, negedge resetn) begin : p_tx_fsm
    if(!resetn) begin
        tx_state <= FSM_WAIT;
    end else begin
        tx_state <= n_tx_state;
    end
end

//
// Process for controlling the sample counter.
always @(posedge clk, negedge resetn) begin : p_uart_tx_sample_counter
    if(!resetn) begin
        sample_counter <= 8'b0;
    end else if (counter_rst) begin
        sample_counter <= 8'b0;
    end else if (counter_en)  begin
        sample_counter <= sample_counter + 1'b1;
    end
end

//
// Set the current value of the tx line.
always @(posedge clk, negedge resetn) begin : p_set_tx_pin
    if(!resetn) begin
        uart_txd <= 1'b1;
    end else begin
        case(tx_state)
            FSM_WAIT    : uart_txd <= 1'b1;
            FSM_START   : uart_txd <= 1'b0;
            FSM_BIT_0   : uart_txd <= tx_data_reg[0];
            FSM_BIT_1   : uart_txd <= tx_data_reg[1];
            FSM_BIT_2   : uart_txd <= tx_data_reg[2];
            FSM_BIT_3   : uart_txd <= tx_data_reg[3];
            FSM_BIT_4   : uart_txd <= tx_data_reg[4];
            FSM_BIT_5   : uart_txd <= tx_data_reg[5];
            FSM_BIT_6   : uart_txd <= tx_data_reg[6];
            FSM_BIT_7   : uart_txd <= tx_data_reg[7];
            FSM_STOP    : uart_txd <= 1'b1;
            default     : uart_txd <= 1'b1;
        endcase
    end
end

endmodule
