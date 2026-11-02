-- Testbench: or4_gate, 4-input OR, every input combination (16 rows)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_or4_gate is
end entity tb_or4_gate;

architecture sim of tb_or4_gate is
    signal a, b, c, d, y : std_logic := '0';
begin
    dut : entity work.or4_gate port map (a => a, b => b, c => c, d => d, y => y);

    stimulus : process
        variable v      : std_logic_vector(3 downto 0);
        variable errors : natural := 0;
    begin
        for i in 0 to 15 loop
            v := conv_std_logic_vector(i, 4);
            a <= v(3); b <= v(2); c <= v(1); d <= v(0);
            wait for 10 ns;
            if y /= (a or b or c or d) then
                report "FAIL:" & " a=" & str(a) & " b=" & str(b) & " c=" & str(c) & " d=" & str(d) & " -> y=" & str(y) severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_or4_gate: ALL TESTS PASSED";
        else
            report "tb_or4_gate: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
