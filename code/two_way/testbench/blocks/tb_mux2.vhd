-- Testbench: mux2, y = a when s = 0, b when s = 1, every input combination (8 rows)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_mux2 is
end entity tb_mux2;

architecture sim of tb_mux2 is
    signal a, b, s, y : std_logic := '0';
begin
    dut : entity work.mux2 port map (a => a, b => b, s => s, y => y);

    stimulus : process
        variable v      : std_logic_vector(2 downto 0);
        variable want   : std_logic;
        variable errors : natural := 0;
    begin
        for i in 0 to 7 loop
            v := conv_std_logic_vector(i, 3);
            s <= v(2); a <= v(1); b <= v(0);
            wait for 10 ns;
            if s = '1' then want := b; else want := a; end if;
            if y /= want then
                report "FAIL: s=" & str(s) & " a=" & str(a) & " b=" & str(b) & " -> y=" & str(y) severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_mux2: ALL TESTS PASSED";
        else
            report "tb_mux2: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
