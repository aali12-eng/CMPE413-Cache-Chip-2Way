-- Testbench: cache_cell (with its selector), Figures 1 and 2 of the specification
--   write 1 and 0, read back, hold while Chip enable = 0, Read Data high impedance unless read
library ieee;
use ieee.std_logic_1164.all;
use work.tb_pkg.all;

entity tb_cache_cell is
end entity tb_cache_cell;

architecture sim of tb_cache_cell is
    signal write_data, chip_enable, rd_wrn : std_logic := '0';
    signal read_data                        : std_logic;
begin
    dut : entity work.cache_cell
        port map (write_data => write_data, chip_enable => chip_enable, rd_wrn => rd_wrn, read_data => read_data);

    stimulus : process
        type step_t is record
            ce, rw, wd, rd : std_logic;   -- Chip enable, RD/WR, Write Data, expected Read Data
        end record;
        type steps_t is array (natural range <>) of step_t;
        constant STEPS : steps_t := (
            ('1', '0', '1', 'Z'),   -- write 1 (Read Data off while writing)
            ('1', '1', '0', '1'),   -- read: 1
            ('0', '1', '0', 'Z'),   -- chip enable off: Read Data high impedance
            ('0', '0', '0', 'Z'),   -- RD/WR = write but chip enable off: no write
            ('1', '1', '0', '1'),   -- still 1
            ('1', '0', '0', 'Z'),   -- write 0
            ('1', '1', '1', '0'),   -- read: 0
            ('0', '0', '1', 'Z'),   -- no write while chip enable is off
            ('1', '1', '1', '0')    -- still 0
        );
        variable errors : natural := 0;
    begin
        for i in STEPS'range loop
            -- as in the chip: RD/WR and Write Data change only while Chip enable is off, so the
            -- selector never makes a write glitch (the specification's write timing rule)
            chip_enable <= '0';
            wait for 1 ns;
            rd_wrn <= STEPS(i).rw; write_data <= STEPS(i).wd;
            wait for 1 ns;
            chip_enable <= STEPS(i).ce;
            wait for 8 ns;
            if read_data /= STEPS(i).rd then
                report "FAIL step " & str(i) & ": Read Data = " & str(read_data)
                     & ", expected " & str(STEPS(i).rd) severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_cache_cell: ALL TESTS PASSED";
        else
            report "tb_cache_cell: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
