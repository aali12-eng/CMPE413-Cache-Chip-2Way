# tb_dff_en in batch: its signals into vcd/tb_dff_en.vcd
database -open vcddb -vcd -into vcd/tb_dff_en.vcd -default
probe -create -database vcddb :clk :d :load :q
run
exit
