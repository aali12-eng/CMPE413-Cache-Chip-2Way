# tb_chip waveforms. Loaded by ./run_two_way.sh tb_chip
# Records the DUT's signals, lays them out with tb_chip.sv, runs the test.

probe -create -shm :clk :reset :cpu_add :cpu_rd_wrn :start :mem_data :cpu_data :busy :mem_en :mem_add

if {[catch {simvision -input waves/tb_chip.sv}]} {
    puts "tb_chip.tcl: SimVision did not take tb_chip.sv, adding the signals plainly"
    probe -create -waveform :clk :reset :cpu_add :cpu_rd_wrn :start :mem_data :cpu_data :busy :mem_en :mem_add
}

run
