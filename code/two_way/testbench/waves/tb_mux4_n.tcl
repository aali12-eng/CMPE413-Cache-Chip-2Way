# tb_mux4_n waveforms. Loaded by ./run_two_way.sh tb_mux4_n
# Records the DUT's signals, lays them out with tb_mux4_n.sv, runs the test.

probe -create -shm :d0 :d1 :d2 :d3 :s :y

if {[catch {simvision -input waves/tb_mux4_n.sv}]} {
    puts "tb_mux4_n.tcl: SimVision did not take tb_mux4_n.sv, adding the signals plainly"
    probe -create -waveform :d0 :d1 :d2 :d3 :s :y
}

run
