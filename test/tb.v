

// 
// Module: tb
// 
// Notes:
// - Top level simulation testbench.
//

`timescale 1ns/1ns

module tb;
    
reg  clk        ;   // Top level system clock input.
reg  resetn     ;
reg  [3:0] sw   ;   // Slide switches.
wire [2:0] rgb0 ;   // RGB Led 0.
wire [2:0] rgb1 ;   // RGB Led 1.
wire [2:0] rgb2 ;   // RGB Led 2.
wire [2:0] rgb3 ;   // RGB Led 3.
wire [3:0] led  ;   // Green Leds
reg  uart_rxd   ;   // UART Recieve pin.

localparam BIT_RATE = 9600;      // Input bit rate of the UART line.


//
// Make the clock tick at 50MHz.
always begin
    #20 assign clk    = ~clk;
    #40 assign resetn = 1'b1;
end

task send_byte;
    input [7:0] to_send;
    integer i;
    begin
        $display("Sending byte: %b at time %d", to_send, $time);

        #2080 uart_rxd = 1'b0;
        for(i=0; i < 8; i = i+1) begin
            #2080 uart_rxd = to_send[i];
        end
        #2080 uart_rxd = 1'b1;
    end
endtask

initial begin
    
    $dumpfile("waves.vcd");     
    $dumpvars(0,tb);
    $monitor(tb.i_dut.data);

    sw = 4'hF;
    send_byte(8'hAB);
    #500
    send_byte(8'h5C);
    #500
    send_byte(8'hF0);
    #500

    $display("Finish simulation at time %d", $time);
    $finish();
end

//
// Instance the top level implementation module.
impl_top i_dut(
.clk      (clk     ),   // Top level system clock input.
.sw       (sw      ),   // Slide switches.
.rgb0     (rgb0    ),   // RGB Led 0.
.rgb1     (rgb1    ),   // RGB Led 1.
.rgb2     (rgb2    ),   // RGB Led 2.
.rgb3     (rgb3    ),   // RGB Led 3.
.led      (led     ),   // Green Leds
.uart_rxd (uart_rxd)    // UART Recieve pin.
);

endmodule
