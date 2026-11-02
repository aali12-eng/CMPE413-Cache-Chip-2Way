-- Testbench: and_reduce_n (4 bits), y = 1 only when every bit of a is 1, all 16 inputs
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_and_reduce_n is
end entity tb_and_reduce_n;

architecture sim of tb_and_reduce_n is
    signal a : std_logic_vector(3 downto 0) := "0000";
    signal y : std_logic;
begin
    dut : entity work.and_reduce_n generic map (N => 4) port map (a => a, y => y);

    stimulus : process
        variable want   : std_logic;
        variable errors : natural := 0;
    begin
        for i in 0 to 15 loop
            a <= conv_std_logic_vector(i, 4);
            if i = 15 then want := '1'; else want := '0'; end if;
            wait for 10 ns;
            if y /= want then
                report "FAIL: a=" & str(a) & " -> y=" & str(y) severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_and_reduce_n: ALL TESTS PASSED";
        else
            report "tb_and_reduce_n: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
