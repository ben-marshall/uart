
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
input        resetn,   // Asynchronous active low reset.
input  [3:0] sw    ,   // Slide switches.
output [2:0] rgb0  ,   // RGB Led 0.
output [2:0] rgb1  ,   // RGB Led 1.
output [2:0] rgb2  ,   // RGB Led 2.
output [2:0] rgb3  ,   // RGB Led 3.
output [3:0] led   ,   // Green Leds
input  [3:0] btn   ,   // PTM Buttons.
input   wire uart_rxd, // UART Recieve pin.
output  wire uart_txd  // UART transmit pin.
);

// Clock frequency in hertz.
parameter CLK_HZ = 50000000;
parameter BIT_RATE = 9600;

wire [7:0]  uart_dbg;

reg [7:0] leds;

assign led  =    leds[3:0];
assign rgb0 = {2'b0,leds[4]};
assign rgb1 = {2'b0,leds[5]};
assign rgb2 = {2'b0,leds[6]};
assign rgb3 = {2'b0,leds[7]};


always @(posedge clk, negedge resetn) begin : p_top_outputs
    if(!resetn) begin
        leds <= 8'b0;
    end else begin
        leds <= uart_dbg;
    end
end


uart_periph #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  )
) i_uart_periph (
.clk      (clk      )  ,   // Top level system clock input.
.resetn   (sw[0]   )  ,   // Asynchronous active low reset.
.uart_dbg (uart_dbg),
.uart_rxd (uart_rxd )  ,   // UART Recieve pin.
.uart_txd (uart_txd )      // UART Transmit pin.
);

endmodule
