# tb_dff_en waveforms. Loaded by ./run_two_way.sh tb_dff_en
# Records the DUT's signals, lays them out with tb_dff_en.sv, runs the test.

probe -create -shm :clk :d :load :q

if {[catch {simvision -input waves/tb_dff_en.sv}]} {
    puts "tb_dff_en.tcl: SimVision did not take tb_dff_en.sv, adding the signals plainly"
    probe -create -waveform :clk :d :load :q
}

run
