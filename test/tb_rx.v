

// 
// Module: tb
// 
// Notes:
// - Top level simulation testbench.
//

`timescale 1ns/1ns
`define WAVES_FILE "./work/waves-rx.vcd"

module tb;
    
reg        clk          ; // Top level system clock input.
reg        resetn       ;
reg        uart_rxd     ; // UART Recieve pin.

reg        uart_rx_en   ; // Recieve enable
wire       uart_rx_break; // Did we get a BREAK message?
wire       uart_rx_valid; // Valid data recieved and available.
wire [7:0] uart_rx_data ; // The recieved data.

//
// Bit rate of the UART line we are testing.
localparam BIT_RATE = 9600;
localparam BIT_P    = (1/BIT_RATE) * 1000000000;

//
// Period and frequency of the system clock.
localparam CLK_HZ   = 50000000;
localparam CLK_P    = 1000000000 / CLK_HZ;


//
// Make the clock tick.
always begin #CLK_P assign clk    = ~clk; end


//
// Sends a single byte down the UART line.
task send_byte;
    input [7:0] to_send;
    integer i;
    begin
        $display("Sending byte: %d at time %d", to_send, $time);

        #BIT_P;  uart_rxd = 1'b0;
        for(i=0; i < 8; i = i+1) begin
            #BIT_P;  uart_rxd = to_send[i];
        end
        #BIT_P;  uart_rxd = 1'b1;
        #1000;
    end
endtask

//
// Run the test sequence.
initial begin
    resetn  = 1'b0;
    clk     = 1'b0;
    uart_rxd = 1'b1;
    #40 resetn = 1'b1;

    $display("BIT RATE  : %d", BIT_RATE );
    $display("BIT PERIOD: %d", BIT_P    );
    
    $dumpfile(`WAVES_FILE);
    $dumpvars(0,tb);

    uart_rx_en = 1'b1;
    
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
// Instance of the DUT
uart_rx #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  )
) i_uart_rx(
.clk          (clk          ), // Top level system clock input.
.resetn       (resetn       ), // Asynchronous active low reset.
.uart_rxd     (uart_rxd     ), // UART Recieve pin.
.uart_rx_en   (uart_rx_en   ), // Recieve enable
.uart_rx_break(uart_rx_break), // Did we get a BREAK message?
.uart_rx_valid(uart_rx_valid), // Valid data recieved and available.
.uart_rx_data (uart_rx_data )  // The recieved data.
);

endmodule
