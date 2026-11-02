-- Testbench: way_select - all 32 combinations of hit0, hit1, valid0, valid1 and lru_way
-- compared with a reference model (victim = invalid way first, else the LRU way)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_way_select is
end entity tb_way_select;

architecture sim of tb_way_select is
    signal hit0, hit1, valid0, valid1, lru_way : std_logic := '0';
    signal hit, miss, hit_way, victim          : std_logic;
begin
    dut : entity work.way_select
        port map (hit0 => hit0, hit1 => hit1, valid0 => valid0, valid1 => valid1, lru_way => lru_way,
                  hit => hit, miss => miss, hit_way => hit_way, victim => victim);

    stimulus : process
        variable v      : std_logic_vector(4 downto 0);
        variable e_hit, e_vic : std_logic;
        variable errors : natural := 0;
    begin
        for i in 0 to 31 loop
            v := conv_std_logic_vector(i, 5);
            hit0 <= v(4); hit1 <= v(3); valid0 <= v(2); valid1 <= v(1); lru_way <= v(0);
            wait for 10 ns;
            e_hit := v(4) or v(3);
            if v(2) = '0' then e_vic := '0';          -- way 0 invalid
            elsif v(1) = '0' then e_vic := '1';       -- way 1 invalid
            else e_vic := v(0);                       -- both valid: the LRU way
            end if;
            if hit /= e_hit or miss /= not e_hit or hit_way /= v(3) or victim /= e_vic then
                report "FAIL: hit0 hit1 valid0 valid1 lru = " & str(v) & " -> hit=" & str(hit)
                     & " hit_way=" & str(hit_way) & " victim=" & str(victim) severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_way_select: ALL TESTS PASSED";
        else
            report "tb_way_select: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
