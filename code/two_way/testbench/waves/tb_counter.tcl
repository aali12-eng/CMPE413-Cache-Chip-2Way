# tb_counter waveforms. Loaded by ./run_two_way.sh tb_counter
# Records the DUT's signals, lays them out with tb_counter.sv, runs the test.

probe -create -shm :clk :count :restart :q

if {[catch {simvision -input waves/tb_counter.sv}]} {
    puts "tb_counter.tcl: SimVision did not take tb_counter.sv, adding the signals plainly"
    probe -create -waveform :clk :count :restart :q
}

run
