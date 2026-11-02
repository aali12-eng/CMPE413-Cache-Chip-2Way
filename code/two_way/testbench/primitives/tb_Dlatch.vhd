-- Testbench: Dlatch, the course's D latch
--   transparent while clk = 1 (q follows d), holds while clk = 0; qbar = not q
library ieee;
use ieee.std_logic_1164.all;
use work.tb_pkg.all;

entity tb_Dlatch is
end entity tb_Dlatch;

architecture sim of tb_Dlatch is
    signal d, clk, q, qbar : std_logic := '0';
begin
    dut : entity work.Dlatch port map (d => d, clk => clk, q => q, qbar => qbar);

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
        expect('1', "clk=1: q follows d=1");
        d <= '0'; wait for 5 ns;
        expect('0', "clk=1: q follows d=0");
        d <= '1'; wait for 5 ns;
        expect('1', "clk=1: q follows d=1 again");
        clk <= '0'; wait for 5 ns;
        expect('1', "clk falls: holds 1");
        d <= '0'; wait for 5 ns;
        expect('1', "clk=0, d=0: holds 1");
        d <= '1'; wait for 2 ns; d <= '0'; wait for 3 ns;
        expect('1', "clk=0, d toggles: holds 1");
        clk <= '1'; wait for 5 ns;
        expect('0', "clk rises: passes d=0");
        clk <= '0'; d <= '1'; wait for 5 ns;
        expect('0', "clk=0: holds 0");
        if errors = 0 then
            report "tb_Dlatch: ALL TESTS PASSED";
        else
            report "tb_Dlatch: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
