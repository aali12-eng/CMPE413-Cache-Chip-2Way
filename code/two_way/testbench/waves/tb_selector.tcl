# tb_selector waveforms. Loaded by ./run_two_way.sh tb_selector
# Records the DUT's signals, lays them out with tb_selector.sv, runs the test.

probe -create -shm :chip_enable :rd_wrn :read_enable :write_enable

if {[catch {simvision -input waves/tb_selector.sv}]} {
    puts "tb_selector.tcl: SimVision did not take tb_selector.sv, adding the signals plainly"
    probe -create -waveform :chip_enable :rd_wrn :read_enable :write_enable
}

run
