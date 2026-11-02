# tb_hit_miss in batch: its signals into vcd/tb_hit_miss.vcd
database -open vcddb -vcd -into vcd/tb_hit_miss.vcd -default
probe -create -database vcddb :tag :stored_tag :valid :hit :miss
run
exit
