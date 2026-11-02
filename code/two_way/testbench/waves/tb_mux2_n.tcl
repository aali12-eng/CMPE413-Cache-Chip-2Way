# tb_mux2_n waveforms. Loaded by ./run_two_way.sh tb_mux2_n
# Records the DUT's signals, lays them out with tb_mux2_n.sv, runs the test.

probe -create -shm :a :b :s :y

if {[catch {simvision -input waves/tb_mux2_n.sv}]} {
    puts "tb_mux2_n.tcl: SimVision did not take tb_mux2_n.sv, adding the signals plainly"
    probe -create -waveform :a :b :s :y
}

run
