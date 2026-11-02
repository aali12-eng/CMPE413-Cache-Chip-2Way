-- Testbench: mux4_n (8 bits), y = d0 / d1 / d2 / d3 for s = 00 / 01 / 10 / 11
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_mux4_n is
end entity tb_mux4_n;

architecture sim of tb_mux4_n is
    signal d0, d1, d2, d3, y : std_logic_vector(7 downto 0) := (others => '0');
    signal s                 : std_logic_vector(1 downto 0) := "00";
begin
    dut : entity work.mux4_n generic map (N => 8)
        port map (d0 => d0, d1 => d1, d2 => d2, d3 => d3, s => s, y => y);

    stimulus : process
        type bytes_t is array (0 to 3) of std_logic_vector(7 downto 0);
        type sets_t is array (natural range <>) of bytes_t;
        constant SETS : sets_t := (
            ("00010001", "00100010", "01000100", "10001000"),
            ("11111111", "00000000", "10101010", "01010101"),
            ("00000000", "11111111", "01010101", "10101010"));
        variable errors : natural := 0;
    begin
        for i in SETS'range loop
            d0 <= SETS(i)(0); d1 <= SETS(i)(1); d2 <= SETS(i)(2); d3 <= SETS(i)(3);
            for k in 0 to 3 loop
                s <= conv_std_logic_vector(k, 2);
                wait for 10 ns;
                if y /= SETS(i)(k) then
                    report "FAIL: s=" & str(s) & " -> y=" & str(y) & " expected " & str(SETS(i)(k)) severity error;
                    errors := errors + 1;
                end if;
            end loop;
        end loop;
        if errors = 0 then
            report "tb_mux4_n: ALL TESTS PASSED";
        else
            report "tb_mux4_n: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
