-- Testbench: dff, the course's negative edge D flip-flop
--   q takes d on the falling edge of clk and holds it otherwise; qbar = not q
library ieee;
use ieee.std_logic_1164.all;
use work.tb_pkg.all;

entity tb_dff is
end entity tb_dff;

architecture sim of tb_dff is
    signal d, clk, q, qbar : std_logic := '0';
begin
    dut : entity work.dff port map (d => d, clk => clk, q => q, qbar => qbar);

    stimulus : process
        variable errors : natural := 0;
        procedure expect (v : std_logic; what : string) is
        begin
            if q /= v or qbar /= not v then
                report "FAIL: " & what & ": q=" & str(q) & " qbar=" & str(qbar)
                     & " expected q=" & str(v) severity error;
                errors := errors + 1;
            end if;
        end procedure;
    begin
        clk <= '1'; d <= '1'; wait for 5 ns;
        clk <= '0'; wait for 5 ns;
        expect('1', "falling edge loads d=1");
        d <= '0'; wait for 5 ns;
        expect('1', "clk low, d changes: holds");
        clk <= '1'; wait for 5 ns;
        expect('1', "rising edge: holds");
        clk <= '0'; wait for 5 ns;
        expect('0', "falling edge loads d=0");
        d <= '1'; clk <= '1'; wait for 5 ns;
        expect('0', "rising edge with d=1: holds");
        d <= '0'; wait for 2 ns; d <= '1'; wait for 3 ns;
        expect('0', "clk high, d toggles: holds");
        clk <= '0'; wait for 5 ns;
        expect('1', "falling edge loads d=1");
        if errors = 0 then
            report "tb_dff: ALL TESTS PASSED";
        else
            report "tb_dff: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
