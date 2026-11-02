# tb_lru waveforms. Loaded by ./run_two_way.sh tb_lru
# Records the DUT's signals, lays them out with tb_lru.sv, runs the test.

probe -create -shm :clk :reset :block_offset :update :used_way :lru_way

if {[catch {simvision -input waves/tb_lru.sv}]} {
    puts "tb_lru.tcl: SimVision did not take tb_lru.sv, adding the signals plainly"
    probe -create -waveform :clk :reset :block_offset :update :used_way :lru_way
}

run
