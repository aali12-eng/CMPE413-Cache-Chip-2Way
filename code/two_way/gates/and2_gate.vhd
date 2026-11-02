-- 2-input AND gate: y = a and b
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity and2_gate is
    port (
        a, b : in  std_logic;
        y    : out std_logic
    );
end entity and2_gate;

architecture rtl of and2_gate is
begin
    y <= a and b after GATE_DELAY;
end architecture rtl;
