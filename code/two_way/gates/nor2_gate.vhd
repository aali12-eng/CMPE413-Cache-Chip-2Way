-- 2-input NOR gate: y = not (a or b)
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity nor2_gate is
    port (
        a, b : in  std_logic;
        y    : out std_logic
    );
end entity nor2_gate;

architecture rtl of nor2_gate is
begin
    y <= a nor b after GATE_DELAY;
end architecture rtl;
