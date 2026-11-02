-- Testbench: selector, the truth table of Figure 2 of the specification
library ieee;
use ieee.std_logic_1164.all;
use work.tb_pkg.all;

entity tb_selector is
end entity tb_selector;

architecture sim of tb_selector is
    signal chip_enable, rd_wrn, read_enable, write_enable : std_logic := '0';
begin
    dut : entity work.selector
        port map (chip_enable => chip_enable, rd_wrn => rd_wrn,
                  read_enable => read_enable, write_enable => write_enable);

    stimulus : process
        type row_t is record
            ce, rw, re, we : std_logic;
        end record;
        type rows_t is array (natural range <>) of row_t;
        constant TABLE : rows_t := (
            ('0', '0', '0', '0'), ('0', '1', '0', '0'),   -- chip enable 0: neither (RD/WR = x)
            ('1', '1', '1', '0'),                         -- read
            ('1', '0', '0', '1'));                        -- write
        variable errors : natural := 0;
    begin
        for i in TABLE'range loop
            chip_enable <= TABLE(i).ce; rd_wrn <= TABLE(i).rw;
            wait for 10 ns;
            if read_enable /= TABLE(i).re or write_enable /= TABLE(i).we then
                report "FAIL: chip enable=" & str(TABLE(i).ce) & " RD/WR=" & str(TABLE(i).rw)
                     & " -> read enable=" & str(read_enable) & " write enable=" & str(write_enable)
                     severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_selector: ALL TESTS PASSED";
        else
            report "tb_selector: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
