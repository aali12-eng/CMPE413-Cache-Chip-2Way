# tb_mux2 in batch: its signals into vcd/tb_mux2.vcd
database -open vcddb -vcd -into vcd/tb_mux2.vcd -default
probe -create -database vcddb :a :b :s :y
run
exit
