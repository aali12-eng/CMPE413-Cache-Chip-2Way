-- Testbench: chip - CPU model + memory model following the specification's protocol and timing,
-- checked against a reference model of the two-way set associative cache with LRU replacement.
--   CPU    : drives start, RD/WR, CA (and CD for a write) on a positive edge; removes them on the
--            positive edge after it sees busy; reads CD on the positive edge after busy goes low.
--   Memory : latches MA on the positive edge when enable is high; drives byte i of the block on
--            the (8 + 2i)th negative edge after enable went high, stable for 2 clock cycles.
-- Checked for every request: the data read, busy high on the 1st negative edge, busy low on the
-- 2nd (read hit), 3rd (write hit/miss) or 19th (read miss) negative edge, enable for exactly one
-- cycle with MA = tag & block offset & 00 on a read miss, and CD driven for exactly one cycle.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.tb_pkg.all;

entity tb_chip is
    generic (N_RANDOM : natural := 150);
end entity tb_chip;

architecture sim of tb_chip is
    signal clk                    : std_logic := '1';
    signal cpu_add, mem_add       : std_logic_vector(5 downto 0);
    signal cpu_data, mem_data     : std_logic_vector(7 downto 0);
    signal cpu_rd_wrn, start, reset, busy, mem_en : std_logic;
    signal Vdd                    : std_logic := '1';
    signal Gnd                    : std_logic := '0';
    signal done                   : boolean := false;
    signal neg_edges              : natural := 0;     -- negative edge counter
    signal mem_block_addr         : std_logic_vector(5 downto 0) := (others => '0');

    -- the memory: byte at address A holds A * 5 + 17 (mod 256)
    function mem_value (a : natural) return std_logic_vector is
    begin
        return conv_std_logic_vector((a * 5 + 17) mod 256, 8);
    end function;
begin
    dut : entity work.chip
        port map (cpu_add => cpu_add, cpu_data => cpu_data, cpu_rd_wrn => cpu_rd_wrn, start => start,
                  clk => clk, reset => reset, mem_data => mem_data, Vdd => Vdd, Gnd => Gnd,
                  busy => busy, mem_en => mem_en, mem_add => mem_add);

    clk_gen : process   -- as in chip_test: high at 10k ns, low at 10k + 5 ns
    begin
        while not done loop
            clk <= '1'; wait for 5 ns;
            clk <= '0'; wait for 5 ns;
        end loop;
        wait;
    end process clk_gen;

    edge_count : process (clk)
    begin
        if falling_edge(clk) then
            neg_edges <= neg_edges + 1;
        end if;
    end process edge_count;

    -- ---------------- memory model ----------------
    memory : process
        variable base : natural;
        variable e    : natural;   -- negative edges since enable went high
    begin
        mem_data <= (others => 'Z');
        loop
            wait until rising_edge(clk);
            if mem_en = '1' then                       -- memory latches MA on a positive edge
                mem_block_addr <= mem_add;
                base := conv_integer(unsigned(mem_add));
                e := 0;
                for i in 0 to 3 loop
                    -- byte i on the (8 + 2i)th negative edge after enable went high
                    while e < 8 + 2 * i loop
                        wait until falling_edge(clk);
                        e := e + 1;
                    end loop;
                    mem_data <= mem_value(base + i);
                end loop;
                wait until falling_edge(clk);
                wait until falling_edge(clk);          -- last byte stable for 2 cycles
                mem_data <= (others => 'Z');
            end if;
        end loop;
    end process memory;

    -- ---------------- CPU model and checker ----------------
    cpu : process
        -- reference model of the two-way cache: index way * 16 + block * 4 + byte (data),
        -- way * 4 + block (tag, valid); one LRU bit per block offset = the way to replace next
        type bytes_t is array (0 to 31) of std_logic_vector(7 downto 0);
        type tags_t  is array (0 to 7) of natural;
        variable c_data   : bytes_t;
        variable c_tag    : tags_t;
        variable c_valid  : std_logic_vector(7 downto 0) := (others => '0');
        variable c_lru    : std_logic_vector(3 downto 0) := "0000";
        variable errors   : natural := 0;
        variable n_req    : natural := 0;
        variable n_rd_hit, n_rd_miss, n_wr_hit, n_wr_miss : natural := 0;
        variable seed     : natural := 12345;

        function other (w : natural) return std_logic is   -- the other way, as an LRU bit
        begin
            if w = 0 then return '1'; else return '0'; end if;
        end function;

        procedure check (cond : boolean; msg : string) is
        begin
            if not cond then
                report "FAIL: " & msg severity error;
                errors := errors + 1;
            end if;
        end procedure;

        procedure do_reset is
        begin
            wait until rising_edge(clk);
            reset <= '1'; start <= '0';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            reset <= '0';
            c_valid := (others => '0'); c_lru := "0000";
        end procedure;

        -- one CPU request; gap = idle clock cycles before it (0 = back to back)
        procedure request (rd : std_logic; a : natural; d : natural; gap : natural) is
            variable tag, blk, byt : natural;
            variable hit           : boolean;
            variable expected_end  : natural;
            variable start_edge    : natural;
            variable k             : natural;
            variable got           : std_logic_vector(7 downto 0);
            variable expected      : std_logic_vector(7 downto 0);
            variable what          : string(1 to 10);
            variable hw, victim    : natural;           -- way that hits, way a read miss fills
        begin
            tag := a / 16; blk := (a / 4) mod 4; byt := a mod 4;
            hit := false; hw := 0;
            for w in 0 to 1 loop
                if c_valid(w * 4 + blk) = '1' and c_tag(w * 4 + blk) = tag then
                    hit := true; hw := w;
                end if;
            end loop;
            if c_valid(blk) = '0' then victim := 0;              -- an invalid way first,
            elsif c_valid(4 + blk) = '0' then victim := 1;
            elsif c_lru(blk) = '1' then victim := 1;            -- else the LRU way
            else victim := 0;
            end if;
            for i in 1 to gap loop
                wait until rising_edge(clk);
            end loop;
            -- positive edge: start, RD/WR, CA (and CD for a write)
            cpu_add <= conv_std_logic_vector(a, 6); cpu_rd_wrn <= rd; start <= '1';
            if rd = '0' then cpu_data <= conv_std_logic_vector(d, 8); else cpu_data <= (others => 'Z'); end if;
            start_edge := neg_edges;                    -- the next negative edge is number start_edge + 1
            if rd = '1' and hit then expected_end := 2; what := "read hit  "; n_rd_hit := n_rd_hit + 1;
            elsif rd = '1' then expected_end := 19; what := "read miss "; n_rd_miss := n_rd_miss + 1;
            elsif hit then expected_end := 3; what := "write hit "; n_wr_hit := n_wr_hit + 1;
            else expected_end := 3; what := "write miss"; n_wr_miss := n_wr_miss + 1;
            end if;
            n_req := n_req + 1;

            -- negative edge 1: busy goes high; the CPU removes its signals on the next positive edge
            wait until falling_edge(clk); wait for 1 ns;
            check(busy = '1', what & " @" & str(a) & ": busy not high on the 1st negative edge");
            wait until rising_edge(clk);
            cpu_add <= (others => 'Z'); cpu_data <= (others => 'Z'); cpu_rd_wrn <= 'Z'; start <= '0';

            -- follow the request edge by edge until busy goes low
            k := 1;
            loop
                wait until falling_edge(clk); wait for 1 ns;
                k := k + 1;
                if rd = '1' and not hit then          -- read miss: enable for exactly one cycle
                    if k = 2 then
                        check(mem_en = '1', what & " @" & str(a) & ": enable not on at the 2nd negative edge");
                        check(mem_add = conv_std_logic_vector(tag * 16 + blk * 4, 6),
                              what & " @" & str(a) & ": MA = " & str(mem_add));
                    else
                        check(mem_en = '0', what & " @" & str(a) & ": enable on at edge " & str(k));
                        check(mem_add = "ZZZZZZ", what & " @" & str(a) & ": MA driven while enable is off");
                    end if;
                end if;
                exit when busy = '0' or k > 25;
                check(cpu_data = "ZZZZZZZZ", what & " @" & str(a) & ": CD driven while busy");
            end loop;
            check(k = expected_end, what & " @" & str(a) & ": busy low on negative edge " & str(k)
                                    & ", expected " & str(expected_end));

            -- read: the CPU reads CD on the next positive edge; CD is driven for one cycle only
            wait until rising_edge(clk);
            got := cpu_data;
            if rd = '1' then
                if hit then
                    expected := c_data(hw * 16 + blk * 4 + byt);
                    c_lru(blk) := other(hw);            -- the way that hit is now the most recent
                else
                    for i in 0 to 3 loop                -- read miss: the whole block from memory
                        c_data(victim * 16 + blk * 4 + i) := mem_value(tag * 16 + blk * 4 + i);
                    end loop;
                    c_tag(victim * 4 + blk) := tag; c_valid(victim * 4 + blk) := '1';
                    c_lru(blk) := other(victim);
                    expected := c_data(victim * 16 + blk * 4 + byt);
                end if;
                check(got = expected, what & " @" & str(a) & ": CD = " & str(got) & ", expected " & str(expected));
                wait until falling_edge(clk); wait for 1 ns;
                check(cpu_data = "ZZZZZZZZ", what & " @" & str(a) & ": CD still driven after one cycle");
                wait until rising_edge(clk);
            else
                check(got = "ZZZZZZZZ", what & " @" & str(a) & ": CD driven after a write");
                if hit then                              -- write hit updates the way that hit;
                    c_data(hw * 16 + blk * 4 + byt) := conv_std_logic_vector(d, 8);   -- write miss:
                    c_lru(blk) := other(hw);                                          -- no allocate
                end if;
            end if;
        end procedure;

        impure function rnd (n : natural) return natural is   -- small LCG (fits 32-bit integers)
        begin
            seed := (seed * 75 + 74) mod 65537;
            return (seed / 7) mod n;
        end function;
        variable a, d : natural;
    begin
        cpu_add <= (others => 'Z'); cpu_data <= (others => 'Z'); cpu_rd_wrn <= 'Z';
        start <= '0'; reset <= '0';
        do_reset;

        -- ---------------- directed tests ----------------
        request('1', 16#00#, 0, 1);          -- read miss (the course example)
        request('1', 16#01#, 0, 1);          -- read hits in the same block
        request('1', 16#02#, 0, 1);
        request('0', 16#03#, 16#FF#, 1);     -- write hit
        request('1', 16#03#, 0, 1);          -- read back FF
        request('0', 16#3F#, 16#AA#, 1);     -- write miss: no write allocate
        request('1', 16#3F#, 0, 1);          -- so this is a read miss (memory value, not AA)
        request('1', 16#3C#, 0, 0);          -- read hit, back to back
        request('1', 16#10#, 0, 0);          -- tag 01, block 0: read miss into way 1 (way 0 kept)
        request('1', 16#03#, 0, 1);          -- tag 00 is still in way 0: read hit (FF)
        request('1', 16#11#, 0, 0);          -- tag 01 in way 1: read hit
        request('1', 16#20#, 0, 0);          -- tag 10, block 0: replaces the LRU way (way 0, tag 00)
        request('1', 16#12#, 0, 0);          -- tag 01 still in way 1: hit
        request('1', 16#00#, 0, 0);          -- tag 00 was evicted: read miss, replaces LRU (tag 10)
        request('0', 16#13#, 16#C3#, 0);     -- write hit in way 1
        request('1', 16#13#, 0, 0);          -- read C3 from way 1
        request('1', 16#03#, 0, 0);          -- way 0 holds tag 00 from memory again (not FF)
        request('0', 16#25#, 16#5A#, 0);     -- write miss on an invalid block (block 1)
        request('1', 16#25#, 0, 0);          -- read miss
        request('0', 16#25#, 16#5A#, 0);     -- now a write hit
        request('1', 16#25#, 0, 0);          -- read 5A
        do_reset;                            -- reset invalidates every block
        request('1', 16#25#, 0, 1);          -- miss after reset
        report "Directed tests done, errors = " & str(errors);

        -- ---------------- random requests ----------------
        for i in 1 to N_RANDOM loop
            a := rnd(64); d := rnd(256);
            if rnd(10) < 4 then
                request('0', a, d, rnd(3));
            else
                request('1', a, 0, rnd(3));
            end if;
        end loop;

        report "STATS: requests=" & str(n_req) & " read hits=" & str(n_rd_hit) & " read misses=" & str(n_rd_miss)
             & " write hits=" & str(n_wr_hit) & " write misses=" & str(n_wr_miss);
        if errors = 0 then
            report "tb_chip: ALL TESTS PASSED";
        else
            report "tb_chip: " & str(errors) & " TEST(S) FAILED" severity error;
        end if;
        done <= true;
        wait;
    end process cpu;
end architecture sim;
