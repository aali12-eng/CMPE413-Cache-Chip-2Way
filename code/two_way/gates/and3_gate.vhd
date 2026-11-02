-- 3-input AND gate built from two 2-input AND gates: y = a and b and c
library ieee;
use ieee.std_logic_1164.all;

entity and3_gate is
    port (
        a, b, c : in  std_logic;
        y       : out std_logic
    );
end entity and3_gate;

architecture structural of and3_gate is
    signal ab : std_logic;
begin
    u_ab  : entity work.and2_gate port map (a => a,  b => b, y => ab);
    u_abc : entity work.and2_gate port map (a => ab, b => c, y => y);
end architecture structural;
