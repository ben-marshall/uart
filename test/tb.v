

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

//
// Bit rate of the UART line we are testing.
localparam BIT_RATE = 11520;
localparam BIT_P    = (1000000000/BIT_RATE);

//
// Period and frequency of the system clock.
localparam CLK_HZ   = 50000000;
localparam CLK_P    = 1000000000/ CLK_HZ;

assign sw    = {2'b0, 1'b1, resetn};


//
// Make the clock tick.
always begin #(CLK_P/2) assign clk    = ~clk; end


//
// Sends a single byte down the UART line.
task send_byte;
    input [7:0] to_send;
    integer i;
    begin
        $display("Sending byte: %d, %b at time %d", to_send,to_send, $time);

        #BIT_P;  uart_rxd = 1'b0;
        for(i=0; i < 8; i = i+1) begin
            #BIT_P;  uart_rxd = to_send[i];

            //$display("    Bit: %d at time %d", i, $time);
        end
        #BIT_P;  uart_rxd = 1'b1;
        #1000;
    end
endtask

//
// Writes a register via the UART
task write_register;
    input [7:0] register;
    input [7:0] value   ;
    begin
        $display("Write register %d with %h", register, value);
        send_byte(register);
        send_byte(value);
    end
endtask

//
// Reads a register via the UART
task read_register;
    input [7:0] register;
    begin
        $display("Read register: %d", register);
        send_byte(register);
    end
endtask


reg [7:0] bytes;
reg [7:0] p_bytes;

initial begin
    resetn  = 1'b0;
    clk     = 1'b0;
    uart_rxd = 1'b1;
    #40 resetn = 1'b1;
    
    $dumpfile("./work/waves-sys.vcd");     
    $dumpvars(0,tb);
    
    send_byte("A");
    send_byte("1");
    
    send_byte("B");
    send_byte("2");
    
    send_byte("C");
    send_byte("3");
    
    send_byte("D");
    send_byte("4");
    
    send_byte(0);

    send_byte("a");
    send_byte("b");
    send_byte("c");
    send_byte("d");
    
    send_byte(0);
    send_byte(0);

    $display("Finish simulation at time %d", $time);
    $finish();
end

//
// Instance the top level implementation module.
impl_top #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  )
) i_dut (
.clk      (clk     ),   // Top level system clock input.
.sw_0     (sw      ),   // Slide switches.
.led      (led     ),   // Green Leds
.uart_rxd (uart_rxd)    // UART Recieve pin.
);

endmodule
