-- Way selection of the two-way cache
--   hit     = hit0 or hit1,  miss = not hit,  hit_way = hit1 (the way that holds the block)
--   victim  = the way a read miss fills: an invalid way first, else the LRU way
--           = valid0 and (not valid1 or lru_way)
library ieee;
use ieee.std_logic_1164.all;

entity way_select is
    port (
        hit0, hit1     : in  std_logic;   -- Hit/Miss of each way
        valid0, valid1 : in  std_logic;   -- valid bit of the addressed block in each way
        lru_way        : in  std_logic;
        hit            : out std_logic;
        miss           : out std_logic;
        hit_way        : out std_logic;
        victim         : out std_logic
    );
end entity way_select;

architecture structural of way_select is
    signal hit_i, valid1_n, inv1_or_lru : std_logic;
begin
    u_hit  : entity work.or2_gate  port map (a => hit0, b => hit1, y => hit_i);
    u_miss : entity work.not_gate  port map (a => hit_i, y => miss);
    u_v1n  : entity work.not_gate  port map (a => valid1, y => valid1_n);
    u_vor  : entity work.or2_gate  port map (a => valid1_n, b => lru_way, y => inv1_or_lru);
    u_vic  : entity work.and2_gate port map (a => valid0, b => inv1_or_lru, y => victim);
    hit     <= hit_i;
    hit_way <= hit1;
end architecture structural;
