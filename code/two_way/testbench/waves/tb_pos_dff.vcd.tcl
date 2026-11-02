# tb_pos_dff in batch: its signals into vcd/tb_pos_dff.vcd
database -open vcddb -vcd -into vcd/tb_pos_dff.vcd -default
probe -create -database vcddb :clk :d :q
run
exit
