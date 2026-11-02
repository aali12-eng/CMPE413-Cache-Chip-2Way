# tb_cache_way waveforms. Loaded by ./run_two_way.sh tb_cache_way
# Records the DUT's signals, lays them out with tb_cache_way.sv, runs the test.

probe -create -shm :reset :block_select :byte_select :write :fill :write_data :tag_in :read_data :tag_out :valid_out

if {[catch {simvision -input waves/tb_cache_way.sv}]} {
    puts "tb_cache_way.tcl: SimVision did not take tb_cache_way.sv, adding the signals plainly"
    probe -create -waveform :reset :block_select :byte_select :write :fill :write_data :tag_in :read_data :tag_out :valid_out
}

run
