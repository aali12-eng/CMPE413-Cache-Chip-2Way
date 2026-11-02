-- 2-input XOR gate: y = a xor b
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity xor2_gate is
    port (
        a, b : in  std_logic;
        y    : out std_logic
    );
end entity xor2_gate;

architecture rtl of xor2_gate is
begin
    y <= a xor b after GATE_DELAY;
end architecture rtl;
