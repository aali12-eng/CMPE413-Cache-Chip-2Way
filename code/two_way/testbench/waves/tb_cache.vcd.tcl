# tb_cache in batch: its signals into vcd/tb_cache.vcd
database -open vcddb -vcd -into vcd/tb_cache.vcd -default
probe -create -database vcddb :clk :reset :address :fill :fill_byte :write :latch_way :lru_update :write_data :read_data :hit :miss :way
run
exit
