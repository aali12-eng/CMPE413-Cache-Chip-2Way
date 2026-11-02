-- Testbench: cache_block - write the 4 bytes, tag and valid, read them back, buses high
-- impedance when the block is not selected, reset clears valid
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_cache_block is
end entity tb_cache_block;

architecture sim of tb_cache_block is
    signal block_select, reset : std_logic := '0';
    signal byte_select         : std_logic_vector(3 downto 0) := "0000";
    signal data_rd_wrn, tag_rd_wrn, valid_rd_wrn : std_logic := '1';
    signal write_data          : std_logic_vector(7 downto 0) := (others => '0');
    signal tag_in              : std_logic_vector(1 downto 0) := "00";
    signal valid_in            : std_logic := '0';
    signal read_data           : std_logic_vector(7 downto 0);
    signal tag_out             : std_logic_vector(1 downto 0);
    signal valid_out           : std_logic;
begin
    dut : entity work.cache_block
        port map (block_select => block_select, byte_select => byte_select, reset => reset,
                  data_rd_wrn => data_rd_wrn, tag_rd_wrn => tag_rd_wrn, valid_rd_wrn => valid_rd_wrn,
                  write_data => write_data, tag_in => tag_in, valid_in => valid_in,
                  read_data => read_data, tag_out => tag_out, valid_out => valid_out);

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
    begin
        -- 1. reset clears valid (block not even selected)
        reset <= '1'; valid_rd_wrn <= '0'; valid_in <= '0';
        wait for 10 ns;
        reset <= '0'; valid_rd_wrn <= '1';
        block_select <= '1';
        wait for 10 ns;
        check(valid_out = '0', "valid = 0 after reset");

        -- 2. write the 4 bytes with the tag and valid (as during a read miss)
        tag_in <= "10"; valid_in <= '1';
        for i in 0 to 3 loop
            byte_select <= onehot(i); write_data <= conv_std_logic_vector(16#A0# + i, 8);
            wait for 5 ns;
            data_rd_wrn <= '0'; tag_rd_wrn <= '0'; valid_rd_wrn <= '0';   -- write signal on
            wait for 10 ns;
            data_rd_wrn <= '1'; tag_rd_wrn <= '1'; valid_rd_wrn <= '1';   -- write signal off
            wait for 5 ns;
        end loop;

        -- 3. read every byte back
        for i in 0 to 3 loop
            byte_select <= onehot(i);
            wait for 5 ns;
            check(read_data = conv_std_logic_vector(16#A0# + i, 8),
                  "byte " & str(i) & " = " & str(read_data));
        end loop;
        check(tag_out = "10" and valid_out = '1', "tag = 10 and valid = 1");

        -- 4. a write to byte 2 alone (write hit) changes only byte 2
        byte_select <= onehot(2); write_data <= "11111111"; tag_in <= "01";
        wait for 5 ns;
        data_rd_wrn <= '0'; wait for 10 ns; data_rd_wrn <= '1';
        wait for 5 ns;
        check(read_data = "11111111", "byte 2 written");
        byte_select <= onehot(1); wait for 5 ns;
        check(read_data = conv_std_logic_vector(16#A1#, 8), "byte 1 unchanged");
        check(tag_out = "10", "tag unchanged by a data write");

        -- 5. block not selected: shared buses released
        block_select <= '0'; wait for 5 ns;
        check(read_data = "ZZZZZZZZ" and tag_out = "ZZ" and valid_out = 'Z', "buses high impedance");

        -- 6. reset clears valid again
        reset <= '1'; valid_rd_wrn <= '0'; valid_in <= '0'; wait for 10 ns;
        reset <= '0'; valid_rd_wrn <= '1'; block_select <= '1'; wait for 5 ns;
        check(valid_out = '0', "reset invalidates the block");

        if errors = 0 then
            report "tb_cache_block: ALL TESTS PASSED";
        else
            report "tb_cache_block: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process stimulus;
end architecture sim;
