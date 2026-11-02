-- Testbench: tx, the course's transmission gate
--   output = input when sel = 1 and selnot = 0, otherwise Z (high impedance)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_tx is
end entity tb_tx;

architecture sim of tb_tx is
    signal sel, selnot, input, output : std_logic := '0';
begin
    dut : entity work.tx port map (sel => sel, selnot => selnot, input => input, output => output);

    stimulus : process
        variable v      : std_logic_vector(2 downto 0);
        variable want   : std_logic;
        variable errors : natural := 0;
    begin
        for i in 0 to 7 loop
            v := conv_std_logic_vector(i, 3);
            sel <= v(2); selnot <= v(1); input <= v(0);
            wait for 10 ns;
            if sel = '1' and selnot = '0' then
                want := input;
            else
                want := 'Z';
            end if;
            if output /= want then
                report "FAIL: sel=" & str(sel) & " selnot=" & str(selnot) & " input=" & str(input)
                     & " -> output=" & str(output) & " expected " & str(want) severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_tx: ALL TESTS PASSED";
        else
            report "tb_tx: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
