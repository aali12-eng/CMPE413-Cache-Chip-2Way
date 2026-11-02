# tb_cache waveforms. Loaded by ./run_two_way.sh tb_cache
# Records the DUT's signals, lays them out with tb_cache.sv, runs the test.

probe -create -shm :clk :reset :address :fill :fill_byte :write :latch_way :lru_update :write_data :read_data :hit :miss :way

if {[catch {simvision -input waves/tb_cache.sv}]} {
    puts "tb_cache.tcl: SimVision did not take tb_cache.sv, adding the signals plainly"
    probe -create -waveform :clk :reset :address :fill :fill_byte :write :latch_way :lru_update :write_data :read_data :hit :miss :way
}

run
