-- Testbench: counter (5 bits), counts on the negative edge while count = 1, clears when 0,
-- restart = 1 loads 1
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_counter is
end entity tb_counter;

architecture sim of tb_counter is
    signal clk, count : std_logic := '1';
    signal restart    : std_logic := '0';
    signal q          : std_logic_vector(4 downto 0);
    signal done       : boolean := false;
begin
    dut : entity work.counter port map (count => count, restart => restart, clk => clk, q => q);

    clk_gen : process
    begin
        while not done loop
            clk <= '1'; wait for 5 ns;
            clk <= '0'; wait for 5 ns;
        end loop;
        wait;
    end process clk_gen;

    stimulus : process
        variable errors : natural := 0;
        procedure expect (n : natural) is
        begin
            if q /= conv_std_logic_vector(n, 5) then
                report "FAIL: count=" & str(q) & " expected " & str(conv_std_logic_vector(n, 5)) severity error;
                errors := errors + 1;
            end if;
        end procedure;
    begin
        count <= '0';
        wait until falling_edge(clk); wait for 2 ns;
        expect(0);                                   -- cleared
        count <= '1';
        for i in 1 to 20 loop                        -- counts 1 .. 20 (past 19, a read miss)
            wait until falling_edge(clk); wait for 2 ns;
            expect(i);
        end loop;
        count <= '0';
        wait until falling_edge(clk); wait for 2 ns;
        expect(0);                                   -- synchronous clear
        restart <= '1';                              -- restart from 0
        wait until falling_edge(clk); wait for 2 ns;
        expect(1);
        restart <= '0'; count <= '1';
        for i in 2 to 19 loop
            wait until falling_edge(clk); wait for 2 ns;
            expect(i);
        end loop;
        count <= '0'; restart <= '1';                -- restart from 19 (back-to-back request)
        wait until falling_edge(clk); wait for 2 ns;
        expect(1);
        restart <= '0';
        wait until falling_edge(clk); wait for 2 ns;
        expect(0);
        if errors = 0 then
            report "tb_counter: ALL TESTS PASSED";
        else
            report "tb_counter: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        done <= true;
        wait;
    end process stimulus;
end architecture sim;
