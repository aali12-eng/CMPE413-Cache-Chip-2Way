-- Testbench: mux2_n (8 bits), y = a when s = 0, b when s = 1, for several byte pairs
library ieee;
use ieee.std_logic_1164.all;
use work.tb_pkg.all;

entity tb_mux2_n is
end entity tb_mux2_n;

architecture sim of tb_mux2_n is
    signal a, b, y : std_logic_vector(7 downto 0) := (others => '0');
    signal s       : std_logic := '0';
begin
    dut : entity work.mux2_n generic map (N => 8) port map (a => a, b => b, s => s, y => y);

    stimulus : process
        type pair_t is record
            a, b : std_logic_vector(7 downto 0);
        end record;
        type pairs_t is array (natural range <>) of pair_t;
        constant PAIRS : pairs_t := (
            ("00000000", "11111111"), ("11111111", "00000000"),
            ("10101010", "01010101"), ("11001010", "00110101"), ("00010011", "11110000"));
        variable want   : std_logic_vector(7 downto 0);
        variable errors : natural := 0;
    begin
        for i in PAIRS'range loop
            for k in 0 to 1 loop
                a <= PAIRS(i).a; b <= PAIRS(i).b;
                if k = 0 then s <= '0'; want := PAIRS(i).a; else s <= '1'; want := PAIRS(i).b; end if;
                wait for 10 ns;
                if y /= want then
                    report "FAIL: s=" & str(s) & " a=" & str(a) & " b=" & str(b) & " -> y=" & str(y) severity error;
                    errors := errors + 1;
                end if;
            end loop;
        end loop;
        if errors = 0 then
            report "tb_mux2_n: ALL TESTS PASSED";
        else
            report "tb_mux2_n: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
