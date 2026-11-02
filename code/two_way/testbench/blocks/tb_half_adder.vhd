-- Testbench: half_adder, sum = a xor b, carry = a and b, every input combination
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_half_adder is
end entity tb_half_adder;

architecture sim of tb_half_adder is
    signal a, b, sum, carry : std_logic := '0';
begin
    dut : entity work.half_adder port map (a => a, b => b, sum => sum, carry => carry);

    stimulus : process
        variable v      : std_logic_vector(1 downto 0);
        variable errors : natural := 0;
    begin
        for i in 0 to 3 loop
            v := conv_std_logic_vector(i, 2);
            a <= v(1); b <= v(0);
            wait for 10 ns;
            if sum /= (a xor b) or carry /= (a and b) then
                report "FAIL: a=" & str(a) & " b=" & str(b) & " -> sum=" & str(sum)
                     & " carry=" & str(carry) severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_half_adder: ALL TESTS PASSED";
        else
            report "tb_half_adder: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
