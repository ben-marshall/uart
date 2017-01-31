
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
input        clk        ,   // Top level system clock input.
input  [3:0] sw    ,   // Slide switches.
output [2:0] rgb0  ,   // RGB Led 0.
output [2:0] rgb1  ,   // RGB Led 1.
output [2:0] rgb2  ,   // RGB Led 2.
output [2:0] rgb3  ,   // RGB Led 3.
output [3:0] led   ,   // Green Leds
input   wire uart_rxd       // UART Recieve pin.
);

wire        break;
wire [7:0]  data;
wire        valid;
wire        resetn = sw[0];

reg [7:0] leds;

assign led  =    leds[3:0];
assign rgb0 = {3{leds[4]}};
assign rgb1 = {3{leds[5]}};
assign rgb2 = {3{leds[6]}};
assign rgb3 = {3{leds[7]}};


always @(posedge clk, negedge resetn) begin : p_top_outputs
    if(!resetn) begin
        leds <= 8'b0;
    end else if(valid) begin
        leds <= data;
    end
end

//
// Instance the reciever.
uart_rx i_uart_rx(
.clk        (clk        ),   // Top level system clock input.
.resetn     (resetn     ),   // Asynchronous active low reset.
.uart_rxd   (uart_rxd   ),   // UART Recieve pin.
.recv_en    (sw[1]      ),   // Recieve enable
.break      (break      ),   // Did we get a BREAK message?
.recv_valid (valid      ),   // Valid data recieved and available.
.recv_data  (data       )    // The recieved data.
);


endmodule
