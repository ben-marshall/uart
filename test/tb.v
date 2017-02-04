

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
wire [3:0] sw   ;   // Slide switches.
wire [2:0] rgb0 ;   // RGB Led 0.
wire [2:0] rgb1 ;   // RGB Led 1.
wire [2:0] rgb2 ;   // RGB Led 2.
wire [2:0] rgb3 ;   // RGB Led 3.
wire [3:0] led  ;   // Green Leds
reg  uart_rxd   ;   // UART Recieve pin.

localparam BIT_RATE = 9600;      // Input bit rate of the UART line.

assign sw    = {2'b0, 1'b0, resetn};

//
// Make the clock tick at 50MHz.
always begin
    #10 assign clk    = ~clk;
end

task send_byte;
    input [7:0] to_send;
    integer i;
    begin
        $display("Sending byte: %d at time %d", to_send, $time);

        #3520;  uart_rxd = 1'b0;
        for(i=0; i < 8; i = i+1) begin
            #3520;  uart_rxd = to_send[i];
        end
        #3520;  uart_rxd = 1'b1;
    end
endtask

reg [7:0] bytes;
reg [7:0] p_bytes;

initial begin
    resetn  = 1'b0;
    clk     = 1'b0;
    uart_rxd = 1'b1;
    #40 resetn = 1'b1;

    $display("SAMPLES/BIT: %d", i_dut.i_uart_rx.SAMPLES_PER_BIT);
    $display("THRESHOLD  : %d", i_dut.i_uart_rx.SAMPLES_THRESHOLD);
    
    $dumpfile("waves.vcd");     
    $dumpvars(0,tb);
    
    for(bytes = 0; bytes <255; bytes = bytes + 1) begin
        #5000
        send_byte(bytes);
        if(p_bytes == tb.i_dut.data) begin
            $display("[PASS]");
        end else if(bytes>1)begin
            $display("[FAIL]");
        end
        p_bytes = bytes;
    end

    $display("Finish simulation at time %d", $time);
    $finish();
end

//
// Instance the top level implementation module.
impl_top i_dut(
.clk      (clk     ),   // Top level system clock input.
.resetn   (resetn  ),
.sw       (sw      ),   // Slide switches.
.rgb0     (rgb0    ),   // RGB Led 0.
.rgb1     (rgb1    ),   // RGB Led 1.
.rgb2     (rgb2    ),   // RGB Led 2.
.rgb3     (rgb3    ),   // RGB Led 3.
.led      (led     ),   // Green Leds
.uart_rxd (uart_rxd)    // UART Recieve pin.
);

endmodule
