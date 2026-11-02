-- Testbench: not_gate, inverter, every input combination (2 rows)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_not_gate is
end entity tb_not_gate;

architecture sim of tb_not_gate is
    signal a, y : std_logic := '0';
begin
    dut : entity work.not_gate port map (a => a, y => y);

    stimulus : process
        variable v      : std_logic_vector(0 downto 0);
        variable errors : natural := 0;
    begin
        for i in 0 to 1 loop
            v := conv_std_logic_vector(i, 1);
            a <= v(0);
            wait for 10 ns;
            if y /= (not a) then
                report "FAIL:" & " a=" & str(a) & " -> y=" & str(y) severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_not_gate: ALL TESTS PASSED";
        else
            report "tb_not_gate: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
