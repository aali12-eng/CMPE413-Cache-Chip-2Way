# tb_chip in batch: its signals into vcd/tb_chip.vcd
database -open vcddb -vcd -into vcd/tb_chip.vcd -default
probe -create -database vcddb :clk :reset :cpu_add :cpu_rd_wrn :start :mem_data :cpu_data :busy :mem_en :mem_add
run
exit
