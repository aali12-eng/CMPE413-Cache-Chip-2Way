-- Testbench: register_n (N = 8), loads on the negative edge only when load = 1
library ieee;
use ieee.std_logic_1164.all;
use work.tb_pkg.all;

entity tb_register_n is
end entity tb_register_n;

architecture sim of tb_register_n is
    signal clk, load : std_logic := '1';
    signal d, q      : std_logic_vector(7 downto 0) := (others => '0');
    signal done      : boolean := false;
begin
    dut : entity work.register_n generic map (N => 8) port map (d => d, load => load, clk => clk, q => q);

    clk_gen : process   -- same clock as chip_test: high at 10k ns, low at 10k + 5 ns
    begin
        while not done loop
            clk <= '1'; wait for 5 ns;
            clk <= '0'; wait for 5 ns;
        end loop;
        wait;
    end process clk_gen;

    stimulus : process
        type step_t is record
            load : std_logic;
            d, q : std_logic_vector(7 downto 0);   -- input, expected q after the negative edge
        end record;
        type steps_t is array (natural range <>) of step_t;
        constant STEPS : steps_t := (
            ('1', "10100101", "10100101"),   -- load
            ('0', "11110000", "10100101"),   -- hold
            ('0', "00001111", "10100101"),   -- hold
            ('1', "00111100", "00111100"),   -- load
            ('1', "11111111", "11111111"));
        variable errors : natural := 0;
    begin
        for i in STEPS'range loop
            wait until rising_edge(clk);          -- inputs change on the positive edge
            load <= STEPS(i).load; d <= STEPS(i).d;
            wait until falling_edge(clk);         -- register loads on the negative edge
            wait for 2 ns;
            if q /= STEPS(i).q then
                report "FAIL step " & str(i) & ": q=" & str(q) & " expected " & str(STEPS(i).q) severity error;
                errors := errors + 1;
            end if;
        end loop;
        if errors = 0 then
            report "tb_register_n: ALL TESTS PASSED";
        else
            report "tb_register_n: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        done <= true;
        wait;
    end process stimulus;
end architecture sim;
