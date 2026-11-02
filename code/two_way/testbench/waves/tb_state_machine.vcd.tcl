# tb_state_machine in batch: its signals into vcd/tb_state_machine.vcd
database -open vcddb -vcd -into vcd/tb_state_machine.vcd -default
probe -create -database vcddb :clk :reset :start :read_write :hit :count :busy :enable :output_enable :latch_input :latch_output :count_enable :count_restart :fill_byte :hit_result :fill :write :latch_way :lru_update :state
run
exit
