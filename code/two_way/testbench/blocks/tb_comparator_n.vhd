-- Testbench: comparator_n (5 bits, the tag width), eq = 1 when a = b, all 1024 pairs
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_comparator_n is
end entity tb_comparator_n;

architecture sim of tb_comparator_n is
    signal a, b : std_logic_vector(4 downto 0) := "00000";
    signal eq   : std_logic;
begin
    dut : entity work.comparator_n generic map (N => 5) port map (a => a, b => b, eq => eq);

    stimulus : process
        variable want   : std_logic;
        variable errors : natural := 0;
    begin
        for i in 0 to 31 loop
            for k in 0 to 31 loop
                a <= conv_std_logic_vector(i, 5); b <= conv_std_logic_vector(k, 5);
                if i = k then want := '1'; else want := '0'; end if;
                wait for 10 ns;
                if eq /= want then
                    report "FAIL: a=" & str(a) & " b=" & str(b) & " -> eq=" & str(eq) severity error;
                    errors := errors + 1;
                end if;
            end loop;
        end loop;
        if errors = 0 then
            report "tb_comparator_n: ALL TESTS PASSED";
        else
            report "tb_comparator_n: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
