-- LRU (least recently used) bits: one bit per block offset, lru = the way to replace next
--   On the negative edge with update = 1, the bit of the addressed block offset becomes the
--   other way:  lru(block offset) <= not used_way.  reset clears every bit (way 0 first).
--   For two ways one bit per block offset gives exact LRU.
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity lru is
    port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        block_offset : in  std_logic_vector(1 downto 0);
        update       : in  std_logic;   -- the addressed block was used in this cycle
        used_way     : in  std_logic;   -- the way that was used
        lru_way      : out std_logic    -- LRU way of the addressed block offset
    );
end entity lru;

architecture structural of lru is
    signal set_en, load, bits : std_logic_vector(NUM_BLOCKS-1 downto 0);
    signal used_n, rst_n, d   : std_logic;
    signal lru_v              : std_logic_vector(0 downto 0);
begin
    -- only the addressed bit is enabled, and only when update = 1
    u_dec   : entity work.decoder2to4 port map (a => block_offset, en => update, y => set_en);
    u_inv   : entity work.not_gate    port map (a => used_way, y => used_n);
    u_rst_n : entity work.not_gate    port map (a => reset, y => rst_n);
    u_d     : entity work.and2_gate   port map (a => used_n, b => rst_n, y => d);   -- reset loads 0

    g_bit : for i in 0 to NUM_BLOCKS-1 generate
        u_load : entity work.or2_gate port map (a => set_en(i), b => reset, y => load(i));
        u_bit  : entity work.dff_en   port map (d => d, load => load(i), clk => clk, q => bits(i));
    end generate g_bit;

    u_mux : entity work.mux4_n generic map (N => 1)
        port map (d0 => bits(0 downto 0), d1 => bits(1 downto 1), d2 => bits(2 downto 2),
                  d3 => bits(3 downto 3), s => block_offset, y => lru_v);
    lru_way <= lru_v(0);
end architecture structural;
