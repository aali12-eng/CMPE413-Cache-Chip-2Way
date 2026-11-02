-- Testbench: and2_gate, 2-input AND, every input combination (4 rows)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_and2_gate is
end entity tb_and2_gate;

architecture sim of tb_and2_gate is
    signal a, b, y : std_logic := '0';
begin
    dut : entity work.and2_gate port map (a => a, b => b, y => y);

    stimulus : process
        variable v      : std_logic_vector(1 downto 0);
        variable errors : natural := 0;
    begin
        for i in 0 to 3 loop
            v := conv_std_logic_vector(i, 2);
            a <= v(1); b <= v(0);
            wait for 10 ns;
            if y /= (a and b) then
                report "FAIL:" & " a=" & str(a) & " b=" & str(b) & " -> y=" & str(y) severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_and2_gate: ALL TESTS PASSED";
        else
            report "tb_and2_gate: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
