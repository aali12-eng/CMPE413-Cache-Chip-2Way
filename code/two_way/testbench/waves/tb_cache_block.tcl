# tb_cache_block waveforms. Loaded by ./run_two_way.sh tb_cache_block
# Records the DUT's signals, lays them out with tb_cache_block.sv, runs the test.

probe -create -shm :reset :block_select :byte_select :data_rd_wrn :tag_rd_wrn :valid_rd_wrn :write_data :tag_in :valid_in :read_data :tag_out :valid_out

if {[catch {simvision -input waves/tb_cache_block.sv}]} {
    puts "tb_cache_block.tcl: SimVision did not take tb_cache_block.sv, adding the signals plainly"
    probe -create -waveform :reset :block_select :byte_select :data_rd_wrn :tag_rd_wrn :valid_rd_wrn :write_data :tag_in :valid_in :read_data :tag_out :valid_out
}

run
