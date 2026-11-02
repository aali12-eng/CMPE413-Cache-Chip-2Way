-- Selector (decoder) of the cache cell, Figure 2 of the project specification
--   Chip enable | RD/WR | Read enable | Write enable
--        0      |   x   |      0      |      0
--        1      |   1   |      1      |      0
--        1      |   0   |      0      |      1
library ieee;
use ieee.std_logic_1164.all;

entity selector is
    port (
        chip_enable  : in  std_logic;
        rd_wrn       : in  std_logic;   -- 1 = read, 0 = write
        read_enable  : out std_logic;
        write_enable : out std_logic
    );
end entity selector;

architecture structural of selector is
    signal wr : std_logic;
begin
    u_inv  : entity work.not_gate  port map (a => rd_wrn, y => wr);
    u_read : entity work.and2_gate port map (a => chip_enable, b => rd_wrn, y => read_enable);
    u_wr   : entity work.and2_gate port map (a => chip_enable, b => wr,     y => write_enable);
end architecture structural;
