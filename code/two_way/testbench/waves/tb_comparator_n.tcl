# tb_comparator_n waveforms. Loaded by ./run_two_way.sh tb_comparator_n
# Records the DUT's signals, lays them out with tb_comparator_n.sv, runs the test.

probe -create -shm :a :b :eq

if {[catch {simvision -input waves/tb_comparator_n.sv}]} {
    puts "tb_comparator_n.tcl: SimVision did not take tb_comparator_n.sv, adding the signals plainly"
    probe -create -waveform :a :b :eq
}

run
