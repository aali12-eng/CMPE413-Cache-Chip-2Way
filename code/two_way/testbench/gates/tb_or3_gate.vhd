-- Testbench: or3_gate, 3-input OR, every input combination (8 rows)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_or3_gate is
end entity tb_or3_gate;

architecture sim of tb_or3_gate is
    signal a, b, c, y : std_logic := '0';
begin
    dut : entity work.or3_gate port map (a => a, b => b, c => c, y => y);

    stimulus : process
        variable v      : std_logic_vector(2 downto 0);
        variable errors : natural := 0;
    begin
        for i in 0 to 7 loop
            v := conv_std_logic_vector(i, 3);
            a <= v(2); b <= v(1); c <= v(0);
            wait for 10 ns;
            if y /= (a or b or c) then
                report "FAIL:" & " a=" & str(a) & " b=" & str(b) & " c=" & str(c) & " -> y=" & str(y) severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_or3_gate: ALL TESTS PASSED";
        else
            report "tb_or3_gate: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
