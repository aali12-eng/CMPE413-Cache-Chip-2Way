-- Cache cell (one bit), Figure 1 of the project specification
--   Write Data -> positive level sensitive latch (Dlatch) -> Tx gate -> Read Data
--   The selector turns Chip enable and RD/WR into the latch's Write enable and the
--   Tx gate's Read enable. Read Data is high impedance unless the cell is being read,
--   so the Read Data outputs of many cells can share one bit line.
library ieee;
use ieee.std_logic_1164.all;

entity cache_cell is
    port (
        write_data  : in  std_logic;
        chip_enable : in  std_logic;
        rd_wrn      : in  std_logic;   -- 1 = read, 0 = write
        read_data   : out std_logic    -- 'Z' when not read
    );
end entity cache_cell;

architecture structural of cache_cell is
    signal read_enable, read_enable_n, write_enable : std_logic;
    signal stored, stored_n                         : std_logic;
begin
    u_sel   : entity work.selector
        port map (chip_enable => chip_enable, rd_wrn => rd_wrn,
                  read_enable => read_enable, write_enable => write_enable);
    u_latch : entity work.Dlatch port map (d => write_data, clk => write_enable, q => stored, qbar => stored_n);
    u_inv   : entity work.not_gate port map (a => read_enable, y => read_enable_n);
    u_tx    : entity work.tx
        port map (sel => read_enable, selnot => read_enable_n, input => stored, output => read_data);
end architecture structural;
