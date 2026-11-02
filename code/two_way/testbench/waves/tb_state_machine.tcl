# tb_state_machine waveforms. Loaded by ./run_two_way.sh tb_state_machine
# Records the DUT's signals, lays them out with tb_state_machine.sv, runs the test.

probe -create -shm :clk :reset :start :read_write :hit :count :busy :enable :output_enable :latch_input :latch_output :count_enable :count_restart :fill_byte :hit_result :fill :write :latch_way :lru_update :state

if {[catch {simvision -input waves/tb_state_machine.sv}]} {
    puts "tb_state_machine.tcl: SimVision did not take tb_state_machine.sv, adding the signals plainly"
    probe -create -waveform :clk :reset :start :read_write :hit :count :busy :enable :output_enable :latch_input :latch_output :count_enable :count_restart :fill_byte :hit_result :fill :write :latch_way :lru_update :state
}

run
