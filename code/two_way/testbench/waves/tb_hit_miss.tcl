# tb_hit_miss waveforms. Loaded by ./run_two_way.sh tb_hit_miss
# Records the DUT's signals, lays them out with tb_hit_miss.sv, runs the test.

probe -create -shm :tag :stored_tag :valid :hit :miss

if {[catch {simvision -input waves/tb_hit_miss.sv}]} {
    puts "tb_hit_miss.tcl: SimVision did not take tb_hit_miss.sv, adding the signals plainly"
    probe -create -waveform :tag :stored_tag :valid :hit :miss
}

run
