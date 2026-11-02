# tb_and_reduce_n waveforms. Loaded by ./run_two_way.sh tb_and_reduce_n
# Records the DUT's signals, lays them out with tb_and_reduce_n.sv, runs the test.

probe -create -shm :a :y

if {[catch {simvision -input waves/tb_and_reduce_n.sv}]} {
    puts "tb_and_reduce_n.tcl: SimVision did not take tb_and_reduce_n.sv, adding the signals plainly"
    probe -create -waveform :a :y
}

run
