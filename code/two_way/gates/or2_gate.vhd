-- 2-input OR gate: y = a or b
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity or2_gate is
    port (
        a, b : in  std_logic;
        y    : out std_logic
    );
end entity or2_gate;

architecture rtl of or2_gate is
begin
    y <= a or b after GATE_DELAY;
end architecture rtl;
