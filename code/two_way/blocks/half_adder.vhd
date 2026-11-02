-- Half adder: sum = a xor b, carry = a and b
library ieee;
use ieee.std_logic_1164.all;

entity half_adder is
    port (
        a, b  : in  std_logic;
        sum   : out std_logic;
        carry : out std_logic
    );
end entity half_adder;

architecture structural of half_adder is
begin
    u_sum   : entity work.xor2_gate port map (a => a, b => b, y => sum);
    u_carry : entity work.and2_gate port map (a => a, b => b, y => carry);
end architecture structural;
