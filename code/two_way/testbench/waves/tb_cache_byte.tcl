# tb_cache_byte waveforms. Loaded by ./run_two_way.sh tb_cache_byte
# Records the DUT's signals, lays them out with tb_cache_byte.sv, runs the test.

probe -create -shm :write_data :chip_enable :rd_wrn :read_data

if {[catch {simvision -input waves/tb_cache_byte.sv}]} {
    puts "tb_cache_byte.tcl: SimVision did not take tb_cache_byte.sv, adding the signals plainly"
    probe -create -waveform :write_data :chip_enable :rd_wrn :read_data
}

run
