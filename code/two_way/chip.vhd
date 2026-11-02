-- Cache chip (CMPE 413/640 project, extra credit): two-way set associative with LRU replacement,
-- byte addressable, 32 bytes (2 ways of 4 blocks x 4 bytes), write through with no write allocate.
-- Read hit 2 clocks, write hit/miss 3, read miss 19 (the same timing as the direct mapped chip).
--
-- Ports match the component in the course testbench chip_test.vhd:
--   CPU Address (CA)   cpu_add    6-bit address from the CPU
--   CPU Data (CD)      cpu_data   8-bit bidirectional: write data in, read data out
--   Read_Write         cpu_rd_wrn 1 = read, 0 = write
--   Start / Busy       start, busy
--   Reset / Clock      reset, clk
--   Memory Address(MA) mem_add    6-bit address to the memory, last two bits 00
--   Memory Data (MD)   mem_data   8-bit data from the memory
--   Enable             mem_en     memory read request
-- The chip works on the negative edge of clk. busy and enable change on negative edges;
-- CD and MA are high impedance when the chip is not driving them.
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity chip is
    port (
        cpu_add    : in    std_logic_vector(5 downto 0);
        cpu_data   : inout std_logic_vector(7 downto 0);
        cpu_rd_wrn : in    std_logic;
        start      : in    std_logic;
        clk        : in    std_logic;
        reset      : in    std_logic;
        mem_data   : in    std_logic_vector(7 downto 0);
        Vdd        : in    std_logic;
        Gnd        : in    std_logic;
        busy       : out   std_logic;
        mem_en     : out   std_logic;
        mem_add    : out   std_logic_vector(5 downto 0)
    );
end entity chip;

architecture structural of chip is
    -- registered CPU request (latched on the negative edge after start)
    signal ca_r                       : std_logic_vector(ADDR_W-1 downto 0);
    signal cd_r                       : std_logic_vector(DATA_W-1 downto 0);
    signal rw_r                       : std_logic;

    -- cache
    signal write_data, read_data, out_r : std_logic_vector(DATA_W-1 downto 0);
    signal tag_hit, tag_miss            : std_logic;   -- tag/valid compare of the cache (held after CHECK)
    signal hit, miss                    : std_logic;   -- hit/miss of the request (from the end of CHECK)

    -- control
    signal count                                   : std_logic_vector(COUNT_W-1 downto 0);
    signal enable, output_enable, latch_input, latch_output : std_logic;
    signal count_enable, count_restart, fill, write : std_logic;
    signal fill_byte                               : std_logic_vector(1 downto 0);
    signal latch_way, lru_update, way              : std_logic;
    signal state                                   : std_logic_vector(4 downto 0);
    signal oe_n, en_n                              : std_logic;
    signal mem_add_i                               : std_logic_vector(ADDR_W-1 downto 0);
begin
    -- ---------------- Registers for the CPU address, data and read_write ----------------
    u_ca_reg : entity work.register_n generic map (N => ADDR_W)
        port map (d => cpu_add, load => latch_input, clk => clk, q => ca_r);
    u_cd_reg : entity work.register_n generic map (N => DATA_W)
        port map (d => cpu_data, load => latch_input, clk => clk, q => cd_r);
    u_rw_reg : entity work.dff_en
        port map (d => cpu_rd_wrn, load => latch_input, clk => clk, q => rw_r);

    -- ---------------- State machine and clock cycle counter ----------------
    u_sm : entity work.state_machine
        port map (clk => clk, reset => reset, start => start, read_write => rw_r, hit => tag_hit,
                  count => count, busy => busy, enable => enable, output_enable => output_enable,
                  latch_input => latch_input, latch_output => latch_output,
                  count_enable => count_enable, count_restart => count_restart,
                  fill_byte => fill_byte, hit_result => hit, fill => fill, write => write,
                  latch_way => latch_way, lru_update => lru_update, state => state);
    u_counter : entity work.counter
        port map (count => count_enable, restart => count_restart, clk => clk, q => count);
    u_miss    : entity work.not_gate port map (a => hit, y => miss);

    -- ---------------- Cache write data ----------------
    -- read miss: the bytes come from the memory (MD); write hit: from the CPU data register
    u_data_mux : entity work.mux2_n generic map (N => DATA_W)
        port map (a => cd_r, b => mem_data, s => fill, y => write_data);

    -- ---------------- Two-way cache (with its Hit/Miss logic and LRU replacement) ----------------
    -- the cache takes the whole CPU address and splits it into tag, block offset and byte
    -- offset itself; during a read miss the state machine gives the byte of the block being written
    u_cache : entity work.cache
        port map (clk => clk, address => ca_r, fill => fill, fill_byte => fill_byte, write => write,
                  latch_way => latch_way, lru_update => lru_update, reset => reset, Vdd => Vdd,
                  write_data => write_data, read_data => read_data, hit => tag_hit, miss => tag_miss, way => way);

    -- ---------------- Output register and Output Enable onto CPU Data ----------------
    u_out_reg : entity work.register_n generic map (N => DATA_W)
        port map (d => read_data, load => latch_output, clk => clk, q => out_r);
    u_oe_n : entity work.not_gate port map (a => output_enable, y => oe_n);
    g_cd : for i in 0 to DATA_W-1 generate
        u_cd_tx : entity work.tx port map (sel => output_enable, selnot => oe_n, input => out_r(i), output => cpu_data(i));
    end generate g_cd;

    -- ---------------- Memory Address and Enable ----------------
    -- MA = | tag | block offset | 00 | (the block's address), driven only while enable is on
    mem_add_i <= ca_r(5 downto 2) & Gnd & Gnd;
    u_en_n : entity work.not_gate port map (a => enable, y => en_n);
    g_ma : for i in 0 to ADDR_W-1 generate
        u_ma_tx : entity work.tx port map (sel => enable, selnot => en_n, input => mem_add_i(i), output => mem_add(i));
    end generate g_ma;
    mem_en <= enable;
end architecture structural;
