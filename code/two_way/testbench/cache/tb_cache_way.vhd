-- Testbench: cache_way - reset, a block written from memory (tag and valid too), read back,
-- a single-byte write, other blocks untouched, reset again
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_cache_way is
end entity tb_cache_way;

architecture sim of tb_cache_way is
    signal block_select, byte_select : std_logic_vector(3 downto 0) := "0001";
    signal write, fill, reset        : std_logic := '0';
    signal write_data, read_data     : std_logic_vector(7 downto 0) := (others => '0');
    signal tag_in, tag_out           : std_logic_vector(1 downto 0) := "00";
    signal valid_out                 : std_logic;
begin
    dut : entity work.cache_way
        port map (block_select => block_select, byte_select => byte_select, write => write, fill => fill,
                  reset => reset, write_data => write_data, tag_in => tag_in, read_data => read_data,
                  tag_out => tag_out, valid_out => valid_out);

    stimulus : process
        variable errors : natural := 0;
        procedure check (cond : boolean; msg : string) is
        begin
            if not cond then
                report "FAIL: " & msg severity error;
                errors := errors + 1;
            end if;
        end procedure;
        function onehot (i : natural) return std_logic_vector is
            variable v : std_logic_vector(3 downto 0) := "0000";
        begin
            v(i) := '1';
            return v;
        end function;
        procedure sel (blk, byt : natural) is
        begin
            block_select <= onehot(blk); byte_select <= onehot(byt);
            wait for 5 ns;
        end procedure;
        procedure write_pulse is   -- address and data stable 5 ns before and after
        begin
            wait for 5 ns;
            write <= '1'; wait for 10 ns; write <= '0';
            wait for 5 ns;
        end procedure;
    begin
        -- 1. reset: every block invalid
        reset <= '1'; wait for 10 ns; reset <= '0';
        for b in 0 to 3 loop
            sel(b, 0);
            check(valid_out = '0', "block " & str(b) & " invalid after reset");
        end loop;

        -- 2. read miss into block 1 with tag 10: 4 bytes, tag and valid
        tag_in <= "10"; fill <= '1';
        for i in 0 to 3 loop
            block_select <= onehot(1); byte_select <= onehot(i);
            write_data <= conv_std_logic_vector(16#40# + i, 8);
            write_pulse;
        end loop;
        fill <= '0';
        for i in 0 to 3 loop
            sel(1, i);
            check(read_data = conv_std_logic_vector(16#40# + i, 8), "block 1 byte " & str(i) & " = " & str(read_data));
        end loop;
        check(tag_out = "10" and valid_out = '1', "block 1: tag 10, valid");

        -- 3. other blocks untouched
        sel(0, 0); check(valid_out = '0', "block 0 still invalid");
        sel(3, 0); check(valid_out = '0', "block 3 still invalid");

        -- 4. write hit to block 1 byte 2 (fill = 0): tag and valid unchanged
        block_select <= onehot(1); byte_select <= onehot(2); write_data <= "11001100"; tag_in <= "01";
        write_pulse;
        sel(1, 2);
        check(read_data = "11001100" and tag_out = "10" and valid_out = '1', "byte 2 written, tag/valid unchanged");

        -- 5. reset invalidates block 1
        reset <= '1'; wait for 10 ns; reset <= '0';
        sel(1, 0);
        check(valid_out = '0', "block 1 invalid after the second reset");

        if errors = 0 then
            report "tb_cache_way: ALL TESTS PASSED";
        else
            report "tb_cache_way: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
