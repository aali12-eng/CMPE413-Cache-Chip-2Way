# All chip_test waveforms (every internal signal). In the SimVision Console:  source waves_full.tcl
# Adds the signals to the waveform window in groups (top to bottom) and runs to 370 ns.

# testbench: clock, CPU interface, memory interface
probe -create -waveform :clk_count :clk :reset
probe -create -waveform :cpu_add :cpu_data :cpu_rd_wrn :start :busy
probe -create -waveform :mem_add :mem_data :mem_en

# chip: registered request, state machine and its outputs
probe -create -waveform :c1:ca_r :c1:cd_r :c1:rw_r
probe -create -waveform :c1:state :c1:count :c1:fill :c1:write :c1:latch_input :c1:latch_output :c1:output_enable :c1:enable
probe -create -waveform :c1:latch_way :c1:lru_update

# hit / miss and the way
probe -create -waveform :c1:hit :c1:miss :c1:way

# inside the cache: address split, both ways (valid, stored tag, hit), LRU and victim
probe -create -waveform :c1:u_cache:tag :c1:u_cache:block_offset :c1:u_cache:byte_offset
probe -create -waveform :c1:u_cache:valid0 :c1:u_cache:stored_tag0 :c1:u_cache:hit0
probe -create -waveform :c1:u_cache:valid1 :c1:u_cache:stored_tag1 :c1:u_cache:hit1
probe -create -waveform :c1:u_cache:lru_way :c1:u_cache:victim :c1:u_cache:fill_way
probe -create -waveform :c1:write_data :c1:read_data :c1:out_r

run 370 ns
