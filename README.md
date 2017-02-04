
# UART Implementation

A very simple UART implementation, written in Verilog.

---

This is a really simple implementation of a Universal Asynchronous Reciever
Transmitter (UART) modem. It can be synthesised for use with FPGAs, and is
small enough to sit along side most existing projects as a peripheral.

It was developed with Icarus Verilog and GTKWave, so should cost you nothing
to setup and play with in your own simulations.

I have tested it with a Xilinx Artix-7 FPGA using the Arty Development board
from Digilent. It runs happily using a 50MHz clock and so long as you buffer
the input and output pins properly, should be able to run much faster.

This isn't the smallest or the fastest UART implementation around, but it
should be the easiest to integrated into a project.

## Tools

- [Icarus Verilog](http://iverilog.icarus.com/)
- [GTK Wave](http://gtkwave.sourceforge.net/)

Both can be installed on Ubuntu via the following command:

```sh
$> sudo apt-get install iverilog gtkwave
```

## Simulation

To run the simple testbench, you can use the `Makefile`:

```sh
$> make run
```

This will create a `sim.bin` file in the top level of the project (if the
build works) and a `waves.vcd` if the simulation happens. It's a very
simple testbench that sends 255 bytes to the reciever and looks to see them
echoed back using the transmitter.

## Modules

### `impl_top`

The top level for the implementation (synthesis) of the simple echo test.

### `uart_rx`

The reciever module.

```verilog
module uart_rx(
input  wire         clk        ,   // Top level system clock input.
input  wire         resetn     ,   // Asynchronous active low reset.

input  wire         uart_rxd   ,   // UART Recieve pin.
input  wire         recv_en    ,   // Recieve enable

output wire         break      ,   // Did we get a BREAK message?
output wire         recv_valid ,   // Valid data recieved and available.
output reg  [7:0]   recv_data      // The recieved data.
);

parameter   BIT_RATE = 9600;      // Input bit rate of the UART line.
parameter   CLK_HZ   = 100000000; // Clock frequency in hertz.
```

### `uart_tx`

The transmitter module.

```verilog
module uart_tx(
input  wire         clk        ,   // Top level system clock input.
input  wire         resetn     ,   // Asynchronous active low reset.

output reg          uart_txd   ,   // UART transmit pin.

output wire         tx_busy    ,   // Module busy sending previous item.
input  wire         tx_enable  ,   // Valid data recieved and available.
input  wire [7:0]   tx_data        // The recieved data.
);

parameter   BIT_RATE = 9600;      // Input bit rate of the UART line.
parameter   CLK_HZ   = 100000000; // Clock frequency in hertz.
```
