-- 2-input XNOR gate: y = not (a xor b)  (1-bit equality)
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity xnor2_gate is
    port (
        a, b : in  std_logic;
        y    : out std_logic
    );
end entity xnor2_gate;

architecture rtl of xnor2_gate is
begin
    y <= not (a xor b) after GATE_DELAY;   -- = a xnor b, written without the VHDL-93 operator
end architecture rtl;
