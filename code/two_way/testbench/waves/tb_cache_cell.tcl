# tb_cache_cell waveforms. Loaded by ./run_two_way.sh tb_cache_cell
# Records the DUT's signals, lays them out with tb_cache_cell.sv, runs the test.

probe -create -shm :write_data :chip_enable :rd_wrn :read_data

if {[catch {simvision -input waves/tb_cache_cell.sv}]} {
    puts "tb_cache_cell.tcl: SimVision did not take tb_cache_cell.sv, adding the signals plainly"
    probe -create -waveform :write_data :chip_enable :rd_wrn :read_data
}

run
