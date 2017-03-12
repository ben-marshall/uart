
SRCS_RX = rtl/uart_rx.v test/tb_rx.v
OUT_RX  = work/sim-rx.bin
WAV_RX  = work/waves-rx.vcd

LOG_FILE = work/sim.log

all: $(WAV_RX)

$(OUT_RX) : $(SRCS_RX)
	iverilog -o $@ $(SRCS_RX)

$(WAV_RX$) : $(OUT_RX)
	vvp -l $(LOG_FILE) $<

clean:
	rm -rf ./work
	mkdir -p ./work
