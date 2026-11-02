-- Hit/Miss: compare the tag bits of the address with the tag stored in the addressed block,
-- and check that the block is valid.   hit = valid and (tag = stored tag),  miss = not hit
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity hit_miss is
    port (
        tag        : in  std_logic_vector(TAG_W-1 downto 0);   -- from the CPU address
        stored_tag : in  std_logic_vector(TAG_W-1 downto 0);   -- from the cache
        valid      : in  std_logic;
        hit        : out std_logic;
        miss       : out std_logic
    );
end entity hit_miss;

architecture structural of hit_miss is
    signal tag_equal, hit_i : std_logic;
begin
    u_cmp  : entity work.comparator_n generic map (N => TAG_W) port map (a => tag, b => stored_tag, eq => tag_equal);
    u_hit  : entity work.and2_gate port map (a => valid, b => tag_equal, y => hit_i);
    u_miss : entity work.not_gate  port map (a => hit_i, y => miss);
    hit <= hit_i;
end architecture structural;
