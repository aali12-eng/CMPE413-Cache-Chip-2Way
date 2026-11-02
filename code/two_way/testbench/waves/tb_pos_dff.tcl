# tb_pos_dff waveforms. Loaded by ./run_two_way.sh tb_pos_dff
# Records the DUT's signals, lays them out with tb_pos_dff.sv, runs the test.

probe -create -shm :clk :d :q

if {[catch {simvision -input waves/tb_pos_dff.sv}]} {
    puts "tb_pos_dff.tcl: SimVision did not take tb_pos_dff.sv, adding the signals plainly"
    probe -create -waveform :clk :d :q
}

run
