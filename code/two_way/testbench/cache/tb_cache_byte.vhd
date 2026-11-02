-- Testbench: cache_byte, 8 cache cells sharing chip enable and RD/WR
--   write (enable = 1, RD/WR = 0) stores the byte; read (enable = 1, RD/WR = 1) drives it;
--   read_data is Z whenever the byte is not being read, and the byte keeps its value
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;
use work.tb_pkg.all;

entity tb_cache_byte is
end entity tb_cache_byte;

architecture sim of tb_cache_byte is
    signal write_data  : std_logic_vector(DATA_W-1 downto 0) := (others => '0');
    signal chip_enable : std_logic := '0';
    signal rd_wrn      : std_logic := '1';
    signal read_data   : std_logic_vector(DATA_W-1 downto 0);
begin
    dut : entity work.cache_byte
        port map (write_data => write_data, chip_enable => chip_enable, rd_wrn => rd_wrn,
                  read_data => read_data);

    stimulus : process
        constant ZZ     : std_logic_vector(DATA_W-1 downto 0) := (others => 'Z');
        variable errors : natural := 0;
        procedure expect (v : std_logic_vector; what : string) is
        begin
            if read_data /= v then
                report "FAIL: " & what & ": read_data=" & str(read_data) & " expected " & str(v) severity error;
                errors := errors + 1;
            end if;
        end procedure;
        -- RD/WR and the data settle before chip enable rises, as the state machine does them:
        -- raising enable in the same instant as RD/WR 0 -> 1 would write for one delta cycle
        procedure write_byte (v : std_logic_vector) is
        begin
            write_data <= v; rd_wrn <= '0'; wait for 1 ns;
            chip_enable <= '1'; wait for 9 ns;
            chip_enable <= '0'; wait for 10 ns;
        end procedure;
        procedure read_byte (v : std_logic_vector; what : string) is
        begin
            rd_wrn <= '1'; wait for 1 ns;
            chip_enable <= '1'; wait for 9 ns;
            expect(v, what);
            chip_enable <= '0'; wait for 10 ns;
            expect(ZZ, "after " & what & ", not enabled");
        end procedure;
    begin
        wait for 10 ns;
        expect(ZZ, "not enabled");
        write_byte("10100101");
        expect(ZZ, "after write, not enabled");
        read_byte("10100101", "read 10100101");
        write_byte("01011010");
        read_byte("01011010", "read 01011010");
        -- the byte holds its value while the inputs change and the cell is not written
        write_data <= "11111111"; rd_wrn <= '1'; wait for 10 ns;
        write_data <= "00000000"; rd_wrn <= '0'; wait for 10 ns;
        expect(ZZ, "write data changes, not enabled");
        read_byte("01011010", "read after input changes, value kept");
        write_byte("00000000");
        read_byte("00000000", "read 00000000");
        write_byte("11111111");
        read_byte("11111111", "read 11111111");
        if errors = 0 then
            report "tb_cache_byte: ALL TESTS PASSED";
        else
            report "tb_cache_byte: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
