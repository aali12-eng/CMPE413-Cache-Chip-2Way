# tb_register_n waveforms. Loaded by ./run_two_way.sh tb_register_n
# Records the DUT's signals, lays them out with tb_register_n.sv, runs the test.

probe -create -shm :clk :d :load :q

if {[catch {simvision -input waves/tb_register_n.sv}]} {
    puts "tb_register_n.tcl: SimVision did not take tb_register_n.sv, adding the signals plainly"
    probe -create -waveform :clk :d :load :q
}

run
