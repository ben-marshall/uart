
SRCS_RX = rtl/uart_rx.v \
          test/tb_rx.v
OUT_RX  = work/sim-rx.bin
WAV_RX  = work/waves-rx.vcd

all: $(WAV_RX)

$(OUT_RX) : $(SRCS_RX)
	iverilog -o $@ $<

$(WAV_RX$) : $(OUT_RX)
	vvp $<

clean:
	rm -rf ./work
	mkdir -p ./work
