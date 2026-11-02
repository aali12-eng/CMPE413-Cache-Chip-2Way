# tb_half_adder in batch: its signals into vcd/tb_half_adder.vcd
database -open vcddb -vcd -into vcd/tb_half_adder.vcd -default
probe -create -database vcddb :a :b :sum :carry
run
exit
