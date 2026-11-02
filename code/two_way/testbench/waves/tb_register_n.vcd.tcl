# tb_register_n in batch: its signals into vcd/tb_register_n.vcd
database -open vcddb -vcd -into vcd/tb_register_n.vcd -default
probe -create -database vcddb :clk :d :load :q
run
exit
