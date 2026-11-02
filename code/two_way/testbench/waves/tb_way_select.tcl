# tb_way_select waveforms. Loaded by ./run_two_way.sh tb_way_select
# Records the DUT's signals, lays them out with tb_way_select.sv, runs the test.

probe -create -shm :hit0 :hit1 :valid0 :valid1 :lru_way :hit :miss :hit_way :victim

if {[catch {simvision -input waves/tb_way_select.sv}]} {
    puts "tb_way_select.tcl: SimVision did not take tb_way_select.sv, adding the signals plainly"
    probe -create -waveform :hit0 :hit1 :valid0 :valid1 :lru_way :hit :miss :hit_way :victim
}

run
