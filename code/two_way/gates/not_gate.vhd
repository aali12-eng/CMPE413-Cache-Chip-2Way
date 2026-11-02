-- Inverter: y = not a
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity not_gate is
    port (
        a : in  std_logic;
        y : out std_logic
    );
end entity not_gate;

architecture rtl of not_gate is
begin
    y <= not a after GATE_DELAY;
end architecture rtl;
