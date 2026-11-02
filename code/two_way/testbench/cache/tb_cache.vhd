-- Testbench: two-way cache - driven as the state machine drives it (inputs on the positive edge,
-- sampled on the negative edge, write signal from positive edge to positive edge):
--   two tags in the same block offset live in the two ways; reads come from the way that hit;
--   the victim is the invalid way, then the LRU way; a write miss does not change the LRU;
--   a write hit writes only the way that hit; reset invalidates everything.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_cache is
end entity tb_cache;

architecture sim of tb_cache is
    signal clk                         : std_logic := '1';
    signal address                     : std_logic_vector(5 downto 0) := (others => '0');
    signal fill, write, reset          : std_logic := '0';
    signal latch_way, lru_update       : std_logic := '0';
    signal fill_byte                   : std_logic_vector(1 downto 0) := "00";
    signal Vdd                         : std_logic := '1';
    signal write_data, read_data       : std_logic_vector(7 downto 0) := (others => '0');
    signal hit, miss, way              : std_logic;
    signal done                        : boolean := false;
begin
    dut : entity work.cache
        port map (clk => clk, address => address, fill => fill, fill_byte => fill_byte, write => write,
                  latch_way => latch_way, lru_update => lru_update, reset => reset, Vdd => Vdd,
                  write_data => write_data, read_data => read_data, hit => hit, miss => miss, way => way);

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
        variable got_hit : std_logic;
        procedure check (cond : boolean; msg : string) is
        begin
            if not cond then
                report "FAIL: " & msg severity error;
                errors := errors + 1;
            end if;
        end procedure;
        function addr (tag, blk, byt : natural) return std_logic_vector is
        begin
            return conv_std_logic_vector(tag * 16 + blk * 4 + byt, 6);
        end function;
        -- one CHECK cycle: address and latch_way (the CHECK state: the cache passes its compare
        -- to hit) on a positive edge, and on the negative edge the victim kept and lru_update
        -- (if hit, or a read)
        procedure access_block (tag, blk, byt : natural; rd : boolean) is
        begin
            wait until rising_edge(clk);
            address <= addr(tag, blk, byt);
            latch_way <= '1';
            wait for 2 ns;
            got_hit := hit;
            if hit = '1' or rd then lru_update <= '1'; else lru_update <= '0'; end if;
            wait until falling_edge(clk);
            wait for 1 ns;
            latch_way <= '0'; lru_update <= '0';
        end procedure;
        -- read miss: the 4 bytes from memory into the victim way, one write pulse each
        procedure fill_block (base : natural; expect_way : std_logic; msg : string) is
        begin
            fill <= '1';
            wait for 1 ns;
            check(way = expect_way, msg & ": filling way " & str(way) & ", expected way " & str(expect_way));
            for i in 0 to 3 loop
                fill_byte <= conv_std_logic_vector(i, 2); write_data <= conv_std_logic_vector(base + i, 8);
                wait until rising_edge(clk); write <= '1';
                wait until rising_edge(clk); write <= '0';
                wait until falling_edge(clk);
            end loop;
            fill <= '0';
        end procedure;
        procedure expect_hit (tag, blk, byt : natural; data : natural; w : std_logic; msg : string) is
        begin
            access_block(tag, blk, byt, true);
            check(got_hit = '1', msg & ": miss, expected a hit");
            check(way = w, msg & ": way " & str(way) & ", expected way " & str(w));
            check(read_data = conv_std_logic_vector(data, 8), msg & ": data " & str(read_data));
        end procedure;
    begin
        -- 1. reset
        wait until rising_edge(clk); reset <= '1';
        wait until rising_edge(clk); reset <= '0';

        -- 2. A (tag 0, block 1): read miss, victim = way 0 (both invalid)
        access_block(0, 1, 0, true);
        check(got_hit = '0', "A misses after reset");
        fill_block(16#10#, '0', "A");
        -- 3. B (tag 1, block 1): read miss, victim = way 1 (still invalid)
        access_block(1, 1, 0, true);
        check(got_hit = '0', "B misses");
        fill_block(16#20#, '1', "B");

        -- 4. both blocks are in the cache, each in its own way
        expect_hit(0, 1, 2, 16#12#, '0', "A byte 2");
        expect_hit(1, 1, 3, 16#23#, '1', "B byte 3");
        expect_hit(0, 1, 0, 16#10#, '0', "A byte 0");            -- A used last: B is LRU

        -- 5. C (tag 2, block 1): read miss, the LRU way (B, way 1) is replaced
        access_block(2, 1, 0, true);
        check(got_hit = '0', "C misses");
        fill_block(16#30#, '1', "C replaces the LRU way (B)");

        -- 6. B was evicted; a write miss does not change the LRU
        access_block(1, 1, 0, false);
        check(got_hit = '0', "B misses after the replacement (write miss)");
        expect_hit(0, 1, 1, 16#11#, '0', "A still in way 0");
        expect_hit(2, 1, 2, 16#32#, '1', "C in way 1");

        -- 7. write hit to C byte 2 (way 1 only)
        access_block(2, 1, 2, false);
        check(got_hit = '1', "C write hit");
        write_data <= "10101010";
        wait until rising_edge(clk); write <= '1';
        wait until rising_edge(clk); write <= '0';
        expect_hit(2, 1, 2, 16#AA#, '1', "C byte 2 written");
        expect_hit(0, 1, 2, 16#12#, '0', "A byte 2 unchanged (other way)");

        -- 8. another block offset is still empty; reset empties everything
        access_block(0, 3, 0, false);
        check(got_hit = '0', "block 3 misses");
        wait until rising_edge(clk); reset <= '1';
        wait until rising_edge(clk); reset <= '0';
        access_block(0, 1, 0, false);
        check(got_hit = '0', "A misses after the second reset");

        if errors = 0 then
            report "tb_cache: ALL TESTS PASSED";
        else
            report "tb_cache: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        done <= true;
        wait;
    end process stimulus;
end architecture sim;
