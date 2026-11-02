-- One byte of the cache: 8 cache cells sharing Chip enable and RD/WR
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity cache_byte is
    port (
        write_data  : in  std_logic_vector(DATA_W-1 downto 0);
        chip_enable : in  std_logic;
        rd_wrn      : in  std_logic;
        read_data   : out std_logic_vector(DATA_W-1 downto 0)   -- 'Z' unless read
    );
end entity cache_byte;

architecture structural of cache_byte is
begin
    g_bit : for i in 0 to DATA_W-1 generate
        u_cell : entity work.cache_cell
            port map (write_data => write_data(i), chip_enable => chip_enable, rd_wrn => rd_wrn,
                      read_data => read_data(i));
    end generate g_bit;
end architecture structural;
