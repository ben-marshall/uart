

all: run

build:
	iverilog -o ./sim.bin test/tb.v rtl/impl_top.v rtl/uart_rx.v

run: build
	vvp ./sim.bin
