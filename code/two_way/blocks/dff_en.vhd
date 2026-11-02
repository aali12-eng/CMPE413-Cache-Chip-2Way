-- Register bit with load: negative edge D flip-flop (dff) with a mux2 holding q when load = 0
--   next q = d when load = 1, else q (the chip works on the negative edge of clk)
library ieee;
use ieee.std_logic_1164.all;

entity dff_en is
    port (
        d    : in  std_logic;
        load : in  std_logic;
        clk  : in  std_logic;
        q    : out std_logic
    );
end entity dff_en;

architecture structural of dff_en is
    signal q_i, q_n, d_sel : std_logic;
begin
    u_mux : entity work.mux2 port map (a => q_i, b => d, s => load, y => d_sel);
    u_ff  : entity work.dff  port map (d => d_sel, clk => clk, q => q_i, qbar => q_n);
    q <= q_i;
end architecture structural;
