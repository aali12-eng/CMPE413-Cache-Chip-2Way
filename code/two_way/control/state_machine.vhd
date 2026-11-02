-- State machine of the cache chip (one-hot, negative edge dffs, next-state logic from gates)
--
--   IDLE      : wait for start.                                   start          -> CHECK
--   CHECK     : CPU signals latched, busy on; tag/valid compare.  read  and hit  -> DATA_OUT   (read hit)
--                                                                 read  and miss -> READ_MISS  (read miss)
--                                                                 write          -> WRITE      (write hit/miss)
--   WRITE     : write hit: the write signal is on for one cycle;  always         -> IDLE  (busy off)
--               write miss: nothing is written (no write allocate)
--   READ_MISS : memory enable for one cycle, wait for the memory, write the 4 bytes from memory,
--               then read the requested byte.
--   DATA_OUT  : output enable on for one cycle, busy off.         start          -> CHECK, else IDLE
--
--   The counter gives the clock cycle c of the request: c = 1 after the first negative edge
--   (CHECK), and after the negative edge where busy goes low c = 2 (read hit), 3 (write hit/miss)
--   or 19 (read miss). It is cleared on the next negative edge, or restarted at 1 by a new request.
--   Read miss:  c = 2              enable on (memory address on MA)
--               c = 10,12,14,16    a byte from memory is valid: write signal on from the next
--                                  positive edge for one cycle (bytes 0,1,2,3 of the block)
--               c = 18             read the requested byte               c = 18 -> DATA_OUT
--   hit_result: the hit/miss of the request, kept from the end of CHECK until the next request's
--               CHECK (the tag/valid compare itself changes while a read miss writes the block).
--
--   Read hit: 2 clocks, write hit/miss: 3 clocks, read miss: 19 clocks (from start to the end).
--   Two-way cache: at the end of CHECK, latch_way keeps the victim way and lru_update marks the
--   way used (read hit, write hit, read miss) as the most recently used.
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity state_machine is
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        start         : in  std_logic;
        read_write    : in  std_logic;   -- latched RD/WR: 1 = read
        hit           : in  std_logic;
        count         : in  std_logic_vector(COUNT_W-1 downto 0);
        busy          : out std_logic;
        enable        : out std_logic;   -- memory enable
        output_enable : out std_logic;
        latch_input   : out std_logic;   -- load the CPU address / data / RD/WR registers
        latch_output  : out std_logic;   -- load the output register from the cache
        count_enable  : out std_logic;   -- run the cycle counter (else clear it)
        count_restart : out std_logic;   -- start the cycle counter at 1 (new request)
        fill_byte     : out std_logic_vector(1 downto 0);   -- read miss: byte of the block being written
        hit_result    : out std_logic;   -- hit (1) or miss (0) of the request, from the end of CHECK
        fill          : out std_logic;   -- read miss: write bytes from memory (MD) into the block
        write         : out std_logic;   -- cache write signal (positive edge to positive edge)
        latch_way     : out std_logic;   -- two-way cache: keep the victim way (end of CHECK)
        lru_update    : out std_logic;   -- two-way cache: the way used becomes most recently used
        state         : out std_logic_vector(4 downto 0)   -- one-hot: DATA_OUT READ_MISS WRITE CHECK IDLE
    );
end entity state_machine;

architecture structural of state_machine is
    signal s_idle, s_check, s_write, s_miss, s_out : std_logic;          -- state flip-flops
    signal n_idle, n_check, n_write, n_miss, n_out : std_logic;          -- next state
    signal q_n                                     : std_logic_vector(7 downto 0);
    signal rst_n, rd_n, miss, c0_n, c1_n, c41_n     : std_logic;
    signal waiting, accept, rd_ok, rd_hit, rd_miss, wr_req : std_logic;
    signal miss_on, miss_done, idle_keep, idle_set  : std_logic;
    signal n_miss_i, n_out_i                        : std_logic;
    signal busy_d, enable_d, b1                     : std_logic;
    signal hit_r, wr_hit, byte_valid, wphase_a, wphase : std_logic;
    signal hit_d, hit_load, busy_st, c21, c321, c16    : std_logic;
    signal byte_c                                      : std_logic;
    signal used                                    : std_logic;
begin
    u_rst_n : entity work.not_gate port map (a => reset,      y => rst_n);
    u_rd_n  : entity work.not_gate port map (a => read_write, y => rd_n);
    u_miss  : entity work.not_gate port map (a => hit,        y => miss);
    u_c0_n  : entity work.not_gate port map (a => count(0),   y => c0_n);
    u_c1_n  : entity work.not_gate port map (a => count(1),   y => c1_n);

    -- ---------------- Next-state logic ----------------
    -- a request is accepted in IDLE or DATA_OUT
    u_wait   : entity work.or2_gate  port map (a => s_idle,  b => s_out,  y => waiting);
    u_accept : entity work.and2_gate port map (a => start,   b => waiting, y => accept);
    -- CHECK -> DATA_OUT / READ_MISS / WRITE
    u_rd_ok  : entity work.and2_gate port map (a => s_check, b => read_write, y => rd_ok);
    u_rd_hit : entity work.and2_gate port map (a => rd_ok,   b => hit,  y => rd_hit);
    u_rd_ms  : entity work.and2_gate port map (a => rd_ok,   b => miss, y => rd_miss);
    u_wr_req : entity work.and2_gate port map (a => s_check, b => rd_n, y => wr_req);
    -- READ_MISS until the counter reaches 18 (10010: the only c in 2..18 with bits 4 and 1 set)
    u_c41_n  : entity work.nand2_gate port map (a => count(4), b => count(1), y => c41_n);
    u_ms_on  : entity work.and2_gate port map (a => s_miss,  b => c41_n,  y => miss_on);
    u_ms_dn  : entity work.and3_gate port map (a => s_miss,  b => count(4), c => count(1), y => miss_done);

    u_n_chk  : entity work.and2_gate port map (a => accept,  b => rst_n, y => n_check);
    u_n_wr   : entity work.and2_gate port map (a => wr_req,  b => rst_n, y => n_write);
    u_n_ms_i : entity work.or2_gate  port map (a => rd_miss, b => miss_on,   y => n_miss_i);
    u_n_ms   : entity work.and2_gate port map (a => n_miss_i, b => rst_n, y => n_miss);
    u_n_out_i: entity work.or2_gate  port map (a => rd_hit,  b => miss_done, y => n_out_i);
    u_n_out  : entity work.and2_gate port map (a => n_out_i, b => rst_n, y => n_out);
    -- IDLE: reset, nothing to do in IDLE / DATA_OUT, or the end of a write
    u_keep   : entity work.nor2_gate port map (a => accept, b => reset, y => idle_keep);
    u_kept   : entity work.and2_gate port map (a => waiting, b => idle_keep, y => idle_set);
    u_n_idle : entity work.or3_gate  port map (a => reset, b => idle_set, c => s_write, y => n_idle);

    -- ---------------- State flip-flops ----------------
    u_s_idle  : entity work.dff port map (d => n_idle,  clk => clk, q => s_idle,  qbar => q_n(0));
    u_s_check : entity work.dff port map (d => n_check, clk => clk, q => s_check, qbar => q_n(1));
    u_s_write : entity work.dff port map (d => n_write, clk => clk, q => s_write, qbar => q_n(2));
    u_s_miss  : entity work.dff port map (d => n_miss,  clk => clk, q => s_miss,  qbar => q_n(3));
    u_s_out   : entity work.dff port map (d => n_out,   clk => clk, q => s_out,   qbar => q_n(4));

    -- ---------------- Registered outputs (change on the negative edge) ----------------
    -- busy: on in CHECK, WRITE and READ_MISS
    u_busy_a : entity work.or2_gate  port map (a => n_check, b => n_write, y => b1);
    u_busy_b : entity work.or2_gate  port map (a => b1,      b => n_miss,  y => busy_d);
    u_busy   : entity work.dff port map (d => busy_d, clk => clk, q => busy, qbar => q_n(5));
    -- memory enable: one cycle, on the 2nd negative edge of a read miss
    u_en_d   : entity work.and2_gate port map (a => rd_miss, b => rst_n, y => enable_d);
    u_en     : entity work.dff port map (d => enable_d, clk => clk, q => enable, qbar => q_n(6));
    -- output enable: one cycle in DATA_OUT
    u_oe     : entity work.dff port map (d => n_out, clk => clk, q => output_enable, qbar => q_n(7));
    -- hit of the CHECK cycle, kept for the write and shown as hit_result until the next CHECK;
    -- reset clears it
    u_hit_d  : entity work.and2_gate port map (a => hit,     b => rst_n, y => hit_d);
    u_hit_ld : entity work.or2_gate  port map (a => s_check, b => reset, y => hit_load);
    u_hit_r  : entity work.dff_en port map (d => hit_d, load => hit_load, clk => clk, q => hit_r);

    -- ---------------- Write signal ----------------
    -- write hit: in WRITE if the CHECK cycle hit;  read miss: c = 10, 12, 14 (01010, 01100, 01110:
    -- bit 3 and bit 2 or 1) or 16 (10000: bit 4 without bit 1), always with bit 0 = 0
    u_wr_hit : entity work.and2_gate port map (a => s_write, b => hit_r, y => wr_hit);
    u_c21    : entity work.or2_gate  port map (a => count(2), b => count(1), y => c21);
    u_c321   : entity work.and2_gate port map (a => count(3), b => c21,      y => c321);
    u_c4     : entity work.and2_gate port map (a => count(4), b => c1_n,     y => c16);
    u_byte_c : entity work.or2_gate  port map (a => c321,     b => c16,      y => byte_c);
    u_bv     : entity work.and3_gate port map (a => s_miss, b => byte_c, c => c0_n, y => byte_valid);
    u_wph_a  : entity work.or2_gate  port map (a => wr_hit, b => byte_valid, y => wphase_a);
    u_wphase : entity work.and2_gate port map (a => wphase_a, b => rst_n, y => wphase);
    -- the write signal is the same phase delayed to the positive edge: on for exactly one clock
    -- cycle, from the positive edge after the data is valid to the next positive edge
    u_write  : entity work.pos_dff port map (d => wphase, clk => clk, q => write);

    -- ---------------- Control outputs ----------------
    -- the counter runs in CHECK, WRITE and READ_MISS and restarts at 1 when a request is accepted
    u_bst    : entity work.or3_gate  port map (a => s_check, b => s_write, c => s_miss, y => busy_st);
    u_count  : entity work.and2_gate port map (a => busy_st, b => rst_n, y => count_enable);
    count_restart <= n_check;
    -- byte of the block written by a read miss: c = 10,11 -> 0, 12,13 -> 1, 14,15 -> 2, 16,17 -> 3
    -- (count(2 downto 1) - 1:  bit 1 = count(2) xnor count(1),  bit 0 = not count(1))
    u_fb1    : entity work.xnor2_gate port map (a => count(2), b => count(1), y => fill_byte(1));
    fill_byte(0) <= c1_n;
    hit_result   <= hit_r;

    -- ---------------- Replacement control of the two-way cache ----------------
    -- sampled by the cache on the negative edge that ends CHECK: the victim way is kept for a
    -- read miss, and the way used (read hit, write hit, or the way a read miss fills) becomes
    -- the most recently used. A write miss uses no way (no write allocate).
    u_used   : entity work.or2_gate  port map (a => hit, b => read_write, y => used);
    u_lru    : entity work.and2_gate port map (a => s_check, b => used, y => lru_update);
    latch_way <= s_check;

    latch_input  <= accept;
    latch_output <= n_out;
    fill         <= miss_on;
    state        <= s_out & s_miss & s_write & s_check & s_idle;
end architecture structural;
