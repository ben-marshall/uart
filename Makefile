
SRC_RX = rtl/uart_rx.v test/tb_rx.v
OUT_RX = work/sim-rx.bin
WAV_RX = work/waves-rx.vcd

SRC_TX = rtl/uart_tx.v test/tb_tx.v
OUT_TX = work/sim-tx.bin
WAV_TX = work/waves-tx.vcd

SRC_SYS = rtl/uart_tx.v \
          rtl/uart_rx.v \
          rtl/impl_top.v \
          test/tb.v
OUT_SYS = work/sim-sys.bin
WAV_SYS = work/waves-sys.vcd

LOG_FILE = work/sim.log

all: rx tx sys

rx : $(WAV_RX)
tx : $(WAV_TX)
sys: $(WAV_SYS)

$(OUT_RX) : $(SRC_RX)
	iverilog -o $@ $(SRC_RX)

$(WAV_RX) : $(OUT_RX)
	vvp -l $(LOG_FILE) $<

$(OUT_TX) : $(SRC_TX)
	iverilog -o $@ $(SRC_TX)

$(WAV_TX) : $(OUT_TX)
	vvp -l $(LOG_FILE) $<

$(OUT_SYS) : $(SRC_SYS)
	iverilog -o $@ $(SRC_SYS)

$(WAV_SYS) : $(OUT_SYS)
	vvp -l $(LOG_FILE) $<

clean:
	rm -rf ./work
	mkdir -p ./work
