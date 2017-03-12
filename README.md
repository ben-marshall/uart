
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
$> make rx tx
```

This will build the separate testbenches for the RX and TX modules, run
their simulations, and output their wave files to `./work/`

## Implementation

When implemented on an Arty Development board using the constraints file in
`./constraints` and the Xilinx default synthesis strategy, the following
utilisation numbers are reported:

Module  | Slice LUTs | Slice Registers | Slices | LUT as Logic | LUT FF Pairs
--------|------------|-----------------|--------|--------------|--------------
`uart_periph` | 88   | 92              | 33     | 88           | 60
`uart_rx` | 51       | 47              | 26     | 51           | 29
`uart_tx` | 35       | 31              | 18     | 35           | 21

## Modules

### `impl_top`

The top level for the implementation (synthesis) of the simple echo test.

### `uart_rx`

The reciever module.

```verilog
module uart_rx(
input                   clk          , // Top level system clock input.
input                   resetn       , // Asynchronous active low reset.
input                   uart_rxd     , // UART Recieve pin.
input                   uart_rx_en   , // Recieve enable
output                  uart_rx_break, // Did we get a BREAK message?
output                  uart_rx_valid, // Valid data recieved/available.
output [PAYLOAD_BITS:0] uart_rx_data   // The recieved data.
);

parameter   BIT_RATE = 9600;      // Input bit rate of the UART line.
parameter   CLK_HZ   = 100000000; // Clock frequency in hertz.
parameter   PAYLOAD_BITS    = 8;  // Number of data bits per UART packet.
parameter   STOP_BITS       = 1;  // Stop bits per UART packet.
```

### `uart_tx`

The transmitter module.

```verilog
module uart_tx(
input                     clk         , // Top level system clock input.
input                     resetn      , // Asynchronous active low reset.
output                    uart_txd    , // UART transmit pin.
output                    uart_tx_busy, // Module busy sending previous item.
input                     uart_tx_en  , // Send the data on uart_tx_data
input  [PAYLOAD_BITS-1:0] uart_tx_data  // The data to be sent
);

parameter   BIT_RATE = 9600;      // Input bit rate of the UART line.
parameter   CLK_HZ   = 100000000; // Clock frequency in hertz.
parameter   PAYLOAD_BITS    = 8;  // Number of data bits per UART packet.
parameter   STOP_BITS       = 1;  // Stop bits per UART packet.
```
