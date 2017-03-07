

all: run

build:
	iverilog -o ./sim.bin \
        test/tb.v \
        rtl/impl_top.v \
	    rtl/uart_periph.v \
        rtl/uart_rx.v \
        rtl/uart_tx.v

run: build
	vvp ./sim.bin
