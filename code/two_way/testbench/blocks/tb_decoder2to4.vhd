-- Testbench: decoder2to4, one-hot y(a) = 1 when en = 1, all 0 when en = 0 (8 rows)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_decoder2to4 is
end entity tb_decoder2to4;

architecture sim of tb_decoder2to4 is
    signal a  : std_logic_vector(1 downto 0) := "00";
    signal en : std_logic := '0';
    signal y  : std_logic_vector(3 downto 0);
begin
    dut : entity work.decoder2to4 port map (a => a, en => en, y => y);

    stimulus : process
        variable want   : std_logic_vector(3 downto 0);
        variable errors : natural := 0;
    begin
        for e in 0 to 1 loop
            for i in 0 to 3 loop
                a <= conv_std_logic_vector(i, 2);
                want := (others => '0');
                if e = 1 then en <= '1'; want(i) := '1'; else en <= '0'; end if;
                wait for 10 ns;
                if y /= want then
                    report "FAIL: en=" & str(en) & " a=" & str(a) & " -> y=" & str(y)
                         & " expected " & str(want) severity error;
                    errors := errors + 1;
                end if;
            end loop;
        end loop;
        if errors = 0 then
            report "tb_decoder2to4: ALL TESTS PASSED";
        else
            report "tb_decoder2to4: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
