-- Testbench: dff_en, negative edge register bit with load
--   on the falling edge of clk: q takes d when load = 1, keeps its value when load = 0
library ieee;
use ieee.std_logic_1164.all;
use work.tb_pkg.all;

entity tb_dff_en is
end entity tb_dff_en;

architecture sim of tb_dff_en is
    signal d, load, q : std_logic := '0';
    signal clk        : std_logic := '1';
    signal done       : boolean := false;
begin
    dut : entity work.dff_en port map (d => d, load => load, clk => clk, q => q);

    clk_gen : process
    begin
        while not done loop
            clk <= '1'; wait for 5 ns;
            clk <= '0'; wait for 5 ns;
        end loop;
        wait;
    end process clk_gen;

    stimulus : process
        type row_t is record
            d, load, q : std_logic;           -- inputs before the edge, q after it
        end record;
        type rows_t is array (natural range <>) of row_t;
        constant TABLE : rows_t := (
            ('1', '1', '1'),                  -- load 1
            ('0', '0', '1'),                  -- hold 1
            ('0', '0', '1'),
            ('0', '1', '0'),                  -- load 0
            ('1', '0', '0'),                  -- hold 0
            ('1', '1', '1'),                  -- load 1
            ('1', '1', '1'));                 -- load 1 again
        variable errors : natural := 0;
    begin
        for i in TABLE'range loop
            d <= TABLE(i).d; load <= TABLE(i).load;
            wait until falling_edge(clk); wait for 2 ns;
            if q /= TABLE(i).q then
                report "FAIL: d=" & str(TABLE(i).d) & " load=" & str(TABLE(i).load)
                     & " -> q=" & str(q) & " expected " & str(TABLE(i).q) severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_dff_en: ALL TESTS PASSED";
        else
            report "tb_dff_en: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        done <= true;
        wait;
    end process stimulus;
end architecture sim;
