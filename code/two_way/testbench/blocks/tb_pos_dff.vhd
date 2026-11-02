-- Testbench: pos_dff, positive edge D flip-flop (the dff on the inverted clock)
--   q takes d on the rising edge of clk and holds it otherwise
library ieee;
use ieee.std_logic_1164.all;
use work.tb_pkg.all;

entity tb_pos_dff is
end entity tb_pos_dff;

architecture sim of tb_pos_dff is
    signal d, clk, q : std_logic := '0';
begin
    dut : entity work.pos_dff port map (d => d, clk => clk, q => q);

    stimulus : process
        variable errors : natural := 0;
        procedure expect (v : std_logic; what : string) is
        begin
            if q /= v then
                report "FAIL: " & what & ": q=" & str(q) & " expected " & str(v) severity error;
                errors := errors + 1;
            end if;
        end procedure;
    begin
        clk <= '0'; d <= '1'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
        expect('1', "rising edge loads d=1");
        d <= '0'; wait for 5 ns;
        expect('1', "clk high, d changes: holds");
        clk <= '0'; wait for 5 ns;
        expect('1', "falling edge: holds");
        clk <= '1'; wait for 5 ns;
        expect('0', "rising edge loads d=0");
        d <= '1'; clk <= '0'; wait for 5 ns;
        expect('0', "falling edge with d=1: holds");
        clk <= '1'; wait for 5 ns;
        expect('1', "rising edge loads d=1");
        if errors = 0 then
            report "tb_pos_dff: ALL TESTS PASSED";
        else
            report "tb_pos_dff: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
