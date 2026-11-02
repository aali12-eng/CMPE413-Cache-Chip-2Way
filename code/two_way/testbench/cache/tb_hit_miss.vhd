-- Testbench: hit_miss - all 32 combinations of tag, stored tag and valid
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_hit_miss is
end entity tb_hit_miss;

architecture sim of tb_hit_miss is
    signal tag, stored_tag : std_logic_vector(1 downto 0) := "00";
    signal valid, hit, miss : std_logic := '0';
begin
    dut : entity work.hit_miss
        port map (tag => tag, stored_tag => stored_tag, valid => valid, hit => hit, miss => miss);

    stimulus : process
        variable errors   : natural := 0;
        variable expected : std_logic;
    begin
        for v in 0 to 1 loop
            for t in 0 to 3 loop
                for s in 0 to 3 loop
                    tag <= conv_std_logic_vector(t, 2); stored_tag <= conv_std_logic_vector(s, 2);
                    if v = 1 then valid <= '1'; else valid <= '0'; end if;
                    wait for 10 ns;
                    if v = 1 and t = s then expected := '1'; else expected := '0'; end if;
                    if hit /= expected or miss /= not expected then
                        report "FAIL: tag=" & str(tag) & " stored=" & str(stored_tag) & " valid=" & str(valid)
                             & " -> hit=" & str(hit) & " miss=" & str(miss) severity error;
                        errors := errors + 1;
                    end if;
                end loop;
            end loop;
        end loop;
        if errors = 0 then
            report "tb_hit_miss: ALL TESTS PASSED";
        else
            report "tb_hit_miss: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
