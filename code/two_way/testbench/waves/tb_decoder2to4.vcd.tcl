# tb_decoder2to4 in batch: its signals into vcd/tb_decoder2to4.vcd
database -open vcddb -vcd -into vcd/tb_decoder2to4.vcd -default
probe -create -database vcddb :a :en :y
run
exit
