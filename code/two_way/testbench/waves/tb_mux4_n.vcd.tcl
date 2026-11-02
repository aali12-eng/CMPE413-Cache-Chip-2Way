# tb_mux4_n in batch: its signals into vcd/tb_mux4_n.vcd
database -open vcddb -vcd -into vcd/tb_mux4_n.vcd -default
probe -create -database vcddb :d0 :d1 :d2 :d3 :s :y
run
exit
