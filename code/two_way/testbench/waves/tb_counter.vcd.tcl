# tb_counter in batch: its signals into vcd/tb_counter.vcd
database -open vcddb -vcd -into vcd/tb_counter.vcd -default
probe -create -database vcddb :clk :count :restart :q
run
exit
