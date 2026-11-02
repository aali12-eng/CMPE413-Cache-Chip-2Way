-- 4-input OR gate built as a tree of 2-input OR gates: y = a or b or c or d
library ieee;
use ieee.std_logic_1164.all;

entity or4_gate is
    port (
        a, b, c, d : in  std_logic;
        y          : out std_logic
    );
end entity or4_gate;

architecture structural of or4_gate is
    signal ab, cd : std_logic;
begin
    u_ab   : entity work.or2_gate port map (a => a,  b => b,  y => ab);
    u_cd   : entity work.or2_gate port map (a => c,  b => d,  y => cd);
    u_abcd : entity work.or2_gate port map (a => ab, b => cd, y => y);
end architecture structural;
