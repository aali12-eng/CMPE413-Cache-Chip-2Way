-- 3-input OR gate built from two 2-input OR gates: y = a or b or c
library ieee;
use ieee.std_logic_1164.all;

entity or3_gate is
    port (
        a, b, c : in  std_logic;
        y       : out std_logic
    );
end entity or3_gate;

architecture structural of or3_gate is
    signal ab : std_logic;
begin
    u_ab  : entity work.or2_gate port map (a => a,  b => b, y => ab);
    u_abc : entity work.or2_gate port map (a => ab, b => c, y => y);
end architecture structural;
