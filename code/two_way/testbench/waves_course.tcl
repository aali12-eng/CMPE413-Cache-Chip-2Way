# chip_test waveforms with exactly the signals of the course's "Project Waveforms" figures,
# in the same order (READ MISS / WRITE HIT / READ HIT / WRITE MISS). Loaded by "./run_*.sh course";
# or in the simulator Console tab (prompt xcelium>, not SimVision>):
#     reset
#     source waves_course.tcl
# Adds the signals and runs to 370 ns.

probe -create -waveform :clk_count
probe -create -waveform :clock
probe -create -waveform :reset

# CPU interface
probe -create -waveform :cpu_add
probe -create -waveform :cpu_data
probe -create -waveform :cpu_rd_wrn
probe -create -waveform :start
probe -create -waveform :busy

# memory interface
probe -create -waveform :mem_add
probe -create -waveform :mem_data
probe -create -waveform :mem_en

run 370 ns
