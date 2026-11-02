# tb_cache_way in batch: its signals into vcd/tb_cache_way.vcd
database -open vcddb -vcd -into vcd/tb_cache_way.vcd -default
probe -create -database vcddb :reset :block_select :byte_select :write :fill :write_data :tag_in :read_data :tag_out :valid_out
run
exit
