-- Testbench: lru - reset, update of the addressed bit only, update = 0 holds, all bits readable
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_lru is
end entity tb_lru;

architecture sim of tb_lru is
    signal clk                           : std_logic := '1';
    signal reset, update, used_way, lru_way : std_logic := '0';
    signal block_offset                  : std_logic_vector(1 downto 0) := "00";
    signal done                          : boolean := false;
begin
    dut : entity work.lru
        port map (clk => clk, reset => reset, block_offset => block_offset, update => update,
                  used_way => used_way, lru_way => lru_way);

    clk_gen : process
    begin
        while not done loop
            clk <= '1'; wait for 5 ns;
            clk <= '0'; wait for 5 ns;
        end loop;
        wait;
    end process clk_gen;

    stimulus : process
        type bits_t is array (0 to 3) of std_logic;
        variable model  : bits_t := (others => '0');
        variable errors : natural := 0;
        procedure check_all (msg : string) is
        begin
            for i in 0 to 3 loop
                block_offset <= conv_std_logic_vector(i, 2);
                wait for 1 ns;
                if lru_way /= model(i) then
                    report "FAIL: " & msg & ": block " & str(i) & " lru=" & str(lru_way)
                         & " expected " & str(model(i)) severity error;
                    errors := errors + 1;
                end if;
            end loop;
        end procedure;
        -- one clock: inputs set on the positive edge, sampled on the negative edge
        procedure use_block (blk : natural; upd, way : std_logic) is
        begin
            wait until rising_edge(clk);
            block_offset <= conv_std_logic_vector(blk, 2); update <= upd; used_way <= way;
            wait until falling_edge(clk);
            wait for 1 ns;
            update <= '0';
            if upd = '1' then model(blk) := not way; end if;
        end procedure;
    begin
        wait until rising_edge(clk);
        reset <= '1';
        wait until falling_edge(clk); wait for 1 ns;
        reset <= '0';
        check_all("after reset");
        use_block(2, '1', '0');  check_all("block 2 used way 0");
        use_block(2, '1', '1');  check_all("block 2 used way 1");
        use_block(1, '0', '0');  check_all("no update");
        use_block(0, '1', '0'); use_block(1, '1', '1'); use_block(3, '1', '0');
        check_all("every block updated");
        wait until rising_edge(clk); reset <= '1';
        wait until falling_edge(clk); wait for 1 ns; reset <= '0';
        model := (others => '0');
        check_all("after the second reset");
        if errors = 0 then
            report "tb_lru: ALL TESTS PASSED";
        else
            report "tb_lru: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        done <= true;
        wait;
    end process stimulus;
end architecture sim;
