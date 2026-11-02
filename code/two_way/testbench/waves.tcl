# chip_test waveforms for the two-way cache: only the essential signals. Loaded by
# "./run_two_way.sh"; or in the SimVision Console:  source waves.tcl
# Every internal signal (state, tags, valid bits, LRU, ...):  source waves_full.tcl
# Adds the signals to the waveform window (top to bottom) and runs to 370 ns.

# clock and reset
probe -create -waveform :clk :clk_count :reset

# CPU request and the chip's answer
probe -create -waveform :start :cpu_rd_wrn :cpu_add :cpu_data :busy

# memory interface (read miss)
probe -create -waveform :mem_en :mem_add :mem_data

# inside the chip: latched RD/WR (1 = read) and the request's hit/miss (kept from the end of CHECK);
# then the way used, clock cycle of the request (19 at the end of a read miss), cache write, output enable
probe -create -waveform :c1:rw_r :c1:hit :c1:way :c1:count :c1:write :c1:output_enable

run 370 ns
