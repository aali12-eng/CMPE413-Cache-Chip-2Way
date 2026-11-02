-- 2-input NAND gate: y = not (a and b)
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity nand2_gate is
    port (
        a, b : in  std_logic;
        y    : out std_logic
    );
end entity nand2_gate;

architecture rtl of nand2_gate is
begin
    y <= a nand b after GATE_DELAY;
end architecture rtl;
