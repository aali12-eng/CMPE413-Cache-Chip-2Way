# tb_mux2_n in batch: its signals into vcd/tb_mux2_n.vcd
database -open vcddb -vcd -into vcd/tb_mux2_n.vcd -default
probe -create -database vcddb :a :b :s :y
run
exit
