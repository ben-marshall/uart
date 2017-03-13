
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

wire [7:0]  uart_rx_echo_data;
wire        uart_rx_echo_valid;
wire        uart_rx_echo_break;

wire [7:0]  uart_rx_led_data;
wire        uart_rx_led_valid;
wire        uart_rx_led_break;

reg  [7:0]  led_reg;
assign      led = led_reg;

always @(posedge clk, negedge sw_0) begin
    if(!sw_0) begin
        led_reg <= 8'h11;
    end else if (uart_rx_led_valid) begin
        led_reg <= uart_rx_led_data;
    end
end

//
// UART RX
uart_rx #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  )
) i_uart_rx_echo(
.clk          (clk          ), // Top level system clock input.
.resetn       (sw_0         ), // Asynchronous active low reset.
.uart_rxd     (uart_rxd     ), // UART Recieve pin.
.uart_rx_en   ( 1'b1        ), // Recieve enable
.uart_rx_break(uart_rx_echo_break), // Did we get a BREAK message?
.uart_rx_valid(uart_rx_echo_valid), // Valid data recieved and available.
.uart_rx_data (uart_rx_echo_data )  // The recieved data.
);

//
// UART RX
uart_rx #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  )
) i_uart_rx_leds(
.clk          (clk          ), // Top level system clock input.
.resetn       (sw_0         ), // Asynchronous active low reset.
.uart_rxd     (uart_rxd     ), // UART Recieve pin.
.uart_rx_en   ( 1'b1        ), // Recieve enable
.uart_rx_break(uart_rx_led_break), // Did we get a BREAK message?
.uart_rx_valid(uart_rx_led_valid), // Valid data recieved and available.
.uart_rx_data (uart_rx_led_data )  // The recieved data.
);

//
// UART Transmitter module.
//
uart_tx #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  )
) i_uart_tx(
.clk          (clk          ),
.resetn       (sw_0         ),
.uart_txd     (uart_txd     ),
.uart_tx_en   (uart_rx_echo_valid),
.uart_tx_busy (             ),
.uart_tx_data (uart_rx_echo_data ) 
);


endmodule
