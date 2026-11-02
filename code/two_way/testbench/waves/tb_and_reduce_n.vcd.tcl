# tb_and_reduce_n in batch: its signals into vcd/tb_and_reduce_n.vcd
database -open vcddb -vcd -into vcd/tb_and_reduce_n.vcd -default
probe -create -database vcddb :a :y
run
exit
