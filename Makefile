

all: run

build:
	iverilog -o ./work/sim.bin \
        test/tb.v \
        rtl/impl_top.v \
	    rtl/uart_periph.v \
        rtl/uart_rx.v \
        rtl/uart_tx.v

run: build
	vvp ./work/sim.bin

clean:
	rm -rf ./work
	mkdir -p ./work
