# tb_comparator_n in batch: its signals into vcd/tb_comparator_n.vcd
database -open vcddb -vcd -into vcd/tb_comparator_n.vcd -default
probe -create -database vcddb :a :b :eq
run
exit
