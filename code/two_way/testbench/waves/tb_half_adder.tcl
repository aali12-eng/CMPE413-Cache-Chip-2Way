# tb_half_adder waveforms. Loaded by ./run_two_way.sh tb_half_adder
# Records the DUT's signals, lays them out with tb_half_adder.sv, runs the test.

probe -create -shm :a :b :sum :carry

if {[catch {simvision -input waves/tb_half_adder.sv}]} {
    puts "tb_half_adder.tcl: SimVision did not take tb_half_adder.sv, adding the signals plainly"
    probe -create -waveform :a :b :sum :carry
}

run
