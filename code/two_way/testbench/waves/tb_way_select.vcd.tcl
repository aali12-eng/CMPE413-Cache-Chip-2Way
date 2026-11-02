# tb_way_select in batch: its signals into vcd/tb_way_select.vcd
database -open vcddb -vcd -into vcd/tb_way_select.vcd -default
probe -create -database vcddb :hit0 :hit1 :valid0 :valid1 :lru_way :hit :miss :hit_way :victim
run
exit
