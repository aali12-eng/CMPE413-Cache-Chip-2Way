# tb_cache_byte in batch: its signals into vcd/tb_cache_byte.vcd
database -open vcddb -vcd -into vcd/tb_cache_byte.vcd -default
probe -create -database vcddb :write_data :chip_enable :rd_wrn :read_data
run
exit
