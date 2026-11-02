-- 2:1 multiplexer (1 bit) from basic gates: y = (a and not s) or (b and s)
library ieee;
use ieee.std_logic_1164.all;

entity mux2 is
    port (
        a, b : in  std_logic;   -- a selected when s = 0, b when s = 1
        s    : in  std_logic;
        y    : out std_logic
    );
end entity mux2;

architecture structural of mux2 is
    signal s_n, a_sel, b_sel : std_logic;
begin
    u_inv : entity work.not_gate  port map (a => s, y => s_n);
    u_a   : entity work.and2_gate port map (a => a, b => s_n, y => a_sel);
    u_b   : entity work.and2_gate port map (a => b, b => s,   y => b_sel);
    u_or  : entity work.or2_gate  port map (a => a_sel, b => b_sel, y => y);
end architecture structural;
