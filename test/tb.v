

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
localparam BIT_P    = 3520;
localparam CLK_HZ   = 100000000;
localparam CLK_P    = 1000000000 / CLK_HZ;

localparam CMD_WR_MEM_ACCESS_COUNT  = 8'hA0;
localparam CMD_RD_MEM_ACCESS_COUNT  = 8'hA1;

localparam CMD_WR_MEM_ACCESS_ADDR_0 = 8'hB0;
localparam CMD_WR_MEM_ACCESS_ADDR_1 = 8'hB1;
localparam CMD_WR_MEM_ACCESS_ADDR_2 = 8'hB2;
localparam CMD_WR_MEM_ACCESS_ADDR_3 = 8'hB3;

localparam CMD_RD_MEM_ACCESS_ADDR_0 = 8'hC0;
localparam CMD_RD_MEM_ACCESS_ADDR_1 = 8'hC1;
localparam CMD_RD_MEM_ACCESS_ADDR_2 = 8'hC2;
localparam CMD_RD_MEM_ACCESS_ADDR_3 = 8'hC3;

localparam CMD_DO_MEM_WRITE         = 8'hD0;
localparam CMD_DO_MEM_READ          = 8'hD1;

assign sw    = {2'b0, 1'b1, resetn};

//
// Make the clock tick at 50MHz.
always begin
    #CLK_P assign clk    = ~clk;
end

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
    
    $dumpfile("waves.vcd");     
    $dumpvars(0,tb);
    
    read_register(CMD_RD_MEM_ACCESS_COUNT );
    read_register(CMD_RD_MEM_ACCESS_ADDR_0);
    read_register(CMD_RD_MEM_ACCESS_ADDR_1);
    read_register(CMD_RD_MEM_ACCESS_ADDR_2);
    read_register(CMD_RD_MEM_ACCESS_ADDR_3);
    
    write_register(CMD_WR_MEM_ACCESS_COUNT , 8'h34);
    write_register(CMD_WR_MEM_ACCESS_ADDR_0, 8'hAB);
    write_register(CMD_WR_MEM_ACCESS_ADDR_1, 8'hCD);
    write_register(CMD_WR_MEM_ACCESS_ADDR_2, 8'hEF);
    write_register(CMD_WR_MEM_ACCESS_ADDR_3, 8'hCD);
    
    read_register(CMD_RD_MEM_ACCESS_COUNT );
    read_register(CMD_RD_MEM_ACCESS_ADDR_0);
    read_register(CMD_RD_MEM_ACCESS_ADDR_1);
    read_register(CMD_RD_MEM_ACCESS_ADDR_2);
    read_register(CMD_RD_MEM_ACCESS_ADDR_3);
    

    $display("BIT RATE   : %d",i_dut.i_uart_periph.i_uart_rx.BIT_RATE);
    $display("CLK Hz     : %d",i_dut.i_uart_periph.i_uart_rx.CLK_HZ);
    $display("SAMPLES/BIT: %d",i_dut.i_uart_periph.i_uart_rx.SAMPLES_PER_BIT);
    $display("THRESHOLD  : %d",i_dut.i_uart_periph.i_uart_rx.SAMPLES_THRESHOLD);
    

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
