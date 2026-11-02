-- Positive edge D flip-flop: the negative edge dff clocked by the inverted clock
--   Used to make the cache write signal, which the specification requires to be on for
--   exactly one clock cycle, from a positive edge to the next positive edge.
library ieee;
use ieee.std_logic_1164.all;

entity pos_dff is
    port (
        d   : in  std_logic;
        clk : in  std_logic;
        q   : out std_logic
    );
end entity pos_dff;

architecture structural of pos_dff is
    signal clk_n, q_n : std_logic;
begin
    u_inv : entity work.not_gate port map (a => clk, y => clk_n);
    u_ff  : entity work.dff port map (d => d, clk => clk_n, q => q, qbar => q_n);
end architecture structural;
