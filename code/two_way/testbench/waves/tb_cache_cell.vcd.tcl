# tb_cache_cell in batch: its signals into vcd/tb_cache_cell.vcd
database -open vcddb -vcd -into vcd/tb_cache_cell.vcd -default
probe -create -database vcddb :write_data :chip_enable :rd_wrn :read_data
run
exit
