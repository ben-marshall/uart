
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
input        clk   ,   // Top level system clock input.
input        sw    ,   // Slide switches.
input   wire uart_rxd, // UART Recieve pin.
output  wire uart_txd  // UART transmit pin.
);

// Clock frequency in hertz.
parameter CLK_HZ = 50000000;
parameter BIT_RATE = 9600;

wire [7:0]  uart_rx_data;
wire        uart_rx_valid;
wire        uart_rx_break;


//
// Instance of the DUT
uart_rx #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  )
) i_uart_rx(
.clk          (clk          ), // Top level system clock input.
.resetn       (sw           ), // Asynchronous active low reset.
.uart_rxd     (uart_rxd     ), // UART Recieve pin.
.uart_rx_en   ( 1'b1        ), // Recieve enable
.uart_rx_break(uart_rx_break), // Did we get a BREAK message?
.uart_rx_valid(uart_rx_valid), // Valid data recieved and available.
.uart_rx_data (uart_rx_data )  // The recieved data.
);

//
// UART Transmitter module.
//
uart_tx #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  )
) i_uart_tx(
.clk          (clk          ),
.resetn       (sw           ),
.uart_txd     (uart_txd     ),
.uart_tx_en   (uart_rx_valid),
.uart_tx_busy (             ),
.uart_tx_data (uart_rx_data ) 
);


endmodule
