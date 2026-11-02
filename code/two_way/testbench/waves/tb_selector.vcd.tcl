# tb_selector in batch: its signals into vcd/tb_selector.vcd
database -open vcddb -vcd -into vcd/tb_selector.vcd -default
probe -create -database vcddb :chip_enable :rd_wrn :read_enable :write_enable
run
exit
