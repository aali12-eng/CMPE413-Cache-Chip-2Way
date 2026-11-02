# tb_lru in batch: its signals into vcd/tb_lru.vcd
database -open vcddb -vcd -into vcd/tb_lru.vcd -default
probe -create -database vcddb :clk :reset :block_offset :update :used_way :lru_way
run
exit
