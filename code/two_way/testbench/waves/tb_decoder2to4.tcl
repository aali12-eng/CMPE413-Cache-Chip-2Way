# tb_decoder2to4 waveforms. Loaded by ./run_two_way.sh tb_decoder2to4
# Records the DUT's signals, lays them out with tb_decoder2to4.sv, runs the test.

probe -create -shm :a :en :y

if {[catch {simvision -input waves/tb_decoder2to4.sv}]} {
    puts "tb_decoder2to4.tcl: SimVision did not take tb_decoder2to4.sv, adding the signals plainly"
    probe -create -waveform :a :en :y
}

run
