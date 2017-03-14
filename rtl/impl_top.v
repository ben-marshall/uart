
// 
// Module: impl_top
// 
// Notes:
// - Top level module to be used in an implementation.
// - To be used in conjunction with the constraints/defaults.xdc file.
// - Ports can be (un)commented depending on whether they are being used.
// - The constraints file contains a complete list of the available ports
//   including the chipkit/Arduino pins.
//

module impl_top (
input               clk     , // Top level system clock input.
input               sw_0    , // Slide switches.
input               sw_1    , // Slide switches.
input   wire        uart_rxd, // UART Recieve pin.
output  wire        uart_txd, // UART transmit pin.
output  wire [7:0]  led
);

// Clock frequency in hertz.
parameter CLK_HZ = 50000000;
parameter BIT_RATE = 115200;
parameter PAYLOAD_BITS = 8;
parameter STACK_DEPTH =  64;

wire [PAYLOAD_BITS-1:0]  uart_rx_data;
wire        uart_rx_valid;
wire        uart_rx_break;

wire        uart_tx_busy;
wire [PAYLOAD_BITS-1:0]  uart_tx_data;
wire        uart_tx_en;

reg  [PAYLOAD_BITS-1:0]  led_reg;
assign      led = led_reg;

// ------------------------------------------------------------------------- 

reg  [PAYLOAD_BITS-1:0]  stack_data      [0:STACK_DEPTH-1];
reg  [7:0]  stack_counter   ;

reg         sending_stack;

assign uart_tx_data = stack_counter < STACK_DEPTH ? stack_data[stack_counter]
                                                  : uart_rx_data;
assign uart_tx_en   = sending_stack && !uart_tx_busy;

always @(posedge clk, negedge sw_0) begin
    if(!sw_0) begin
        sending_stack <= 1'b0;
    end else if(sending_stack) begin
        sending_stack <= stack_counter != 0;
    end else begin
        sending_stack <= stack_counter == STACK_DEPTH;
    end
end

always @(posedge clk, negedge sw_0) begin
    if(!sw_0) begin
        stack_counter <= 0;
    end else if(sending_stack && !uart_tx_busy) begin
        stack_counter <= stack_counter - 1;
    end else if(uart_rx_valid && stack_counter < STACK_DEPTH) begin
        stack_counter <= stack_counter + 1;
    end
end

genvar stack_i;
generate
    for (stack_i = 0; stack_i < STACK_DEPTH; stack_i = stack_i + 1) 
    begin : stack_gen_loop
        always @(posedge clk, negedge sw_0) begin
            if(!sw_0) begin
                stack_data[stack_i] <= "0";
            end else if (stack_counter == stack_i && 
                         uart_rx_valid            &&
                         !sending_stack            ) begin
                stack_data[stack_i] <= uart_rx_data;
            end
        end
    end
endgenerate

always @(posedge clk, negedge sw_0) begin
    if(!sw_0) begin
        led_reg <= 8'hF0;
    end else begin
        led_reg <= 8'b10;
    end
end


// ------------------------------------------------------------------------- 

//
// UART RX
uart_rx #(
.BIT_RATE(BIT_RATE),
.PAYLOAD_BITS(PAYLOAD_BITS),
.CLK_HZ  (CLK_HZ  )
) i_uart_rx(
.clk          (clk          ), // Top level system clock input.
.resetn       (sw_0         ), // Asynchronous active low reset.
.uart_rxd     (uart_rxd     ), // UART Recieve pin.
.uart_rx_en   (1'b1         ), // Recieve enable
.uart_rx_break(uart_rx_break), // Did we get a BREAK message?
.uart_rx_valid(uart_rx_valid), // Valid data recieved and available.
.uart_rx_data (uart_rx_data )  // The recieved data.
);

//
// UART Transmitter module.
//
uart_tx #(
.BIT_RATE(BIT_RATE),
.PAYLOAD_BITS(PAYLOAD_BITS),
.CLK_HZ  (CLK_HZ  )
) i_uart_tx(
.clk          (clk          ),
.resetn       (sw_0         ),
.uart_txd     (uart_txd     ),
.uart_tx_en   (uart_tx_en   ),
.uart_tx_busy (uart_tx_busy ),
.uart_tx_data (uart_tx_data ) 
);


endmodule
