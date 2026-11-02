-- Testbench: state_machine (with the clock cycle counter) - every scenario of the specification,
-- checked on every clock edge:
--   read hit (2 clocks), write hit and write miss (3 clocks), read miss (19 clocks)
-- After each negative edge k (k = 1 is the first negative edge after start) the testbench checks
-- busy, enable, output enable, the state, the counter (k while the request runs, then 0) and the
-- kept hit/miss; after the following positive edge, the write signal and the byte being written.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_state_machine is
end entity tb_state_machine;

architecture sim of tb_state_machine is
    constant S_IDLE  : std_logic_vector(4 downto 0) := "00001";
    constant S_CHECK : std_logic_vector(4 downto 0) := "00010";
    constant S_WRITE : std_logic_vector(4 downto 0) := "00100";
    constant S_MISS  : std_logic_vector(4 downto 0) := "01000";
    constant S_OUT   : std_logic_vector(4 downto 0) := "10000";

    signal clk                          : std_logic := '1';
    signal reset, start, read_write, hit : std_logic := '0';
    signal count                        : std_logic_vector(4 downto 0);
    signal busy, enable, output_enable, latch_input, latch_output : std_logic;
    signal count_enable, fill, write    : std_logic;
    signal count_restart, hit_result    : std_logic;
    signal fill_byte                    : std_logic_vector(1 downto 0);
    signal latch_way, lru_update        : std_logic;
    signal state                        : std_logic_vector(4 downto 0);
    signal done                         : boolean := false;
begin
    dut : entity work.state_machine
        port map (clk => clk, reset => reset, start => start, read_write => read_write, hit => hit,
                  count => count, busy => busy, enable => enable, output_enable => output_enable,
                  latch_input => latch_input, latch_output => latch_output, count_enable => count_enable,
                  count_restart => count_restart, fill_byte => fill_byte, hit_result => hit_result,
                  fill => fill, write => write, latch_way => latch_way, lru_update => lru_update,
                  state => state);
    u_counter : entity work.counter
        port map (count => count_enable, restart => count_restart, clk => clk, q => count);

    clk_gen : process   -- as in chip_test: high at 10k ns, low at 10k + 5 ns
    begin
        while not done loop
            clk <= '1'; wait for 5 ns;
            clk <= '0'; wait for 5 ns;
        end loop;
        wait;
    end process clk_gen;

    stimulus : process
        variable errors : natural := 0;

        function bool_sl (b : boolean) return std_logic is
        begin
            if b then return '1'; else return '0'; end if;
        end function;

        procedure check (cond : boolean; msg : string) is
        begin
            if not cond then
                report "FAIL: " & msg severity error;
                errors := errors + 1;
            end if;
        end procedure;

        -- one request; scenario: 0 read hit, 1 write hit, 2 write miss, 3 read miss
        procedure run (scenario : natural; name : string) is
            variable n          : natural;
            variable e_busy, e_en, e_oe, e_wr : std_logic;
            variable e_state    : std_logic_vector(4 downto 0);
            variable e_count    : natural;
            variable e_hit      : std_logic;
        begin
            -- the CPU raises start with the request on a positive edge, for one clock
            wait until rising_edge(clk);
            start <= '1';
            if scenario = 0 or scenario = 3 then read_write <= '1'; else read_write <= '0'; end if;
            if scenario = 0 or scenario = 1 then hit <= '1'; else hit <= '0'; end if;
            if scenario = 3 then n := 20; else n := 3; end if;
            for k in 1 to n loop
                wait until falling_edge(clk);                   -- negative edge k
                wait for 2 ns;
                e_busy := '0'; e_en := '0'; e_oe := '0'; e_state := S_IDLE;
                case scenario is
                    when 0 =>                                   -- read hit
                        if k = 1 then e_busy := '1'; e_state := S_CHECK; end if;
                        if k = 2 then e_oe := '1'; e_state := S_OUT; end if;
                    when 1 | 2 =>                               -- write hit / write miss
                        if k = 1 then e_busy := '1'; e_state := S_CHECK; end if;
                        if k = 2 then e_busy := '1'; e_state := S_WRITE; end if;
                    when others =>                              -- read miss
                        if k = 1 then e_busy := '1'; e_state := S_CHECK; end if;
                        if k >= 2 and k <= 18 then e_busy := '1'; e_state := S_MISS; end if;
                        if k = 2 then e_en := '1'; end if;
                        if k = 19 then e_oe := '1'; e_state := S_OUT; end if;
                end case;
                check(busy = e_busy, name & " edge " & str(k) & ": busy=" & str(busy));
                check(enable = e_en, name & " edge " & str(k) & ": enable=" & str(enable));
                check(output_enable = e_oe, name & " edge " & str(k) & ": output enable=" & str(output_enable));
                check(state = e_state, name & " edge " & str(k) & ": state=" & str(state) & " expected " & str(e_state));
                -- the counter: clock cycle k of the request, 0 once it is over
                e_count := k;
                if (scenario = 0 and k > 2) or ((scenario = 1 or scenario = 2) and k > 3) or k > 19 then
                    e_count := 0;
                end if;
                check(count = conv_std_logic_vector(e_count, 5), name & " edge " & str(k) & ": count=" & str(count));
                -- the kept hit/miss: this request's from the end of CHECK (edge 2)
                if k >= 2 then
                    e_hit := bool_sl(scenario = 0 or scenario = 1);
                    check(hit_result = e_hit, name & " edge " & str(k) & ": hit_result=" & str(hit_result));
                end if;
                -- two-way replacement control: only in CHECK; lru_update unless it is a write miss
                if k = 1 then
                    check(latch_way = '1', name & ": latch_way off in CHECK");
                    check(lru_update = bool_sl(scenario /= 2), name & ": lru_update=" & str(lru_update) & " in CHECK");
                else
                    check(latch_way = '0' and lru_update = '0', name & " edge " & str(k) & ": replacement control on outside CHECK");
                end if;
                -- write signal at this negative edge: still on if it started at the previous positive edge
                e_wr := '0';
                if scenario = 1 and k = 3 then e_wr := '1'; end if;
                if scenario = 3 and (k = 11 or k = 13 or k = 15 or k = 17) then e_wr := '1'; end if;
                check(write = e_wr, name & " edge " & str(k) & ": write=" & str(write) & " (mid-pulse)");
                -- the write signal after the following positive edge
                wait until rising_edge(clk);
                if k = 1 then start <= '0'; end if;             -- CPU removes the request (busy seen)
                wait for 2 ns;
                e_wr := '0';
                if scenario = 1 and k = 2 then e_wr := '1'; end if;
                if scenario = 3 and (k = 10 or k = 12 or k = 14 or k = 16) then e_wr := '1'; end if;
                check(write = e_wr, name & " after edge " & str(k) & ": write=" & str(write));
                if scenario = 3 and e_wr = '1' then             -- bytes 0,1,2,3 of the block
                    check(fill_byte = conv_std_logic_vector((k - 10) / 2, 2),
                          name & " after edge " & str(k) & ": fill_byte=" & str(fill_byte));
                end if;
            end loop;
        end procedure;
    begin
        reset <= '1';
        wait until falling_edge(clk); wait until falling_edge(clk);
        wait until rising_edge(clk);
        reset <= '0';
        wait until falling_edge(clk); wait for 2 ns;
        check(state = S_IDLE and busy = '0', "reset -> IDLE, busy off");
        check(hit_result = '0', "reset -> hit_result 0");

        run(0, "read hit");
        run(1, "write hit");
        run(2, "write miss");
        run(3, "read miss");

        if errors = 0 then
            report "tb_state_machine: ALL TESTS PASSED";
        else
            report "tb_state_machine: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        done <= true;
        wait;
    end process stimulus;
end architecture sim;
