
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

module impl_top(
    input   wire clk        ,   // Top level system clock input.
    input   wire sw   [3:0] ,   // Slide switches.
    output  wire rgb0 [2:0] ,   // RGB Led 0.
    output  wire rgb1 [2:0] ,   // RGB Led 1.
    output  wire rgb2 [2:0] ,   // RGB Led 2.
    output  wire rgb3 [2:0] ,   // RGB Led 3.
    output  wire led  [2:0] ,   // Green Leds
    input   wire btn  [3:0] ,   // Push to make buttons.
    input   wire uart_rxd   ,   // UART Recieve pin.
    output  wire uart_txd       // UART Transmit pin.
);


endmodule
