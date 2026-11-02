# tb_cache_block in batch: its signals into vcd/tb_cache_block.vcd
database -open vcddb -vcd -into vcd/tb_cache_block.vcd -default
probe -create -database vcddb :reset :block_select :byte_select :data_rd_wrn :tag_rd_wrn :valid_rd_wrn :write_data :tag_in :valid_in :read_data :tag_out :valid_out
run
exit
