-- The two-way set associative cache (32 bytes) addressed by the CPU address
--   address = | tag | block offset | byte offset |   (5..4, 3..2, 1..0)
--   The block offset selects one block in each of the 2 ways (the specification's "2 sets");
--   the tag is compared with the tags of both blocks (Hit/Miss of each way). On a hit the
--   byte is read from the way that hit. A read miss fills the victim way: an invalid way,
--   else the least recently used one. LRU: the way used by a hit or filled by a read miss
--   becomes the most recently used.
--
--   Control (from the state machine):
--   write      : write signal (one clock cycle, positive edge to positive edge). It writes the
--                way that hit (write hit) or, during a read miss (fill = 1), the victim way,
--                together with its tag and valid bit; the byte offset then comes from fill_byte.
--   latch_way  : at the end of the tag/valid compare (negative edge), keep the victim way for
--                the read miss that may follow (the valid and LRU bits change while it fills).
--   lru_update : at the same negative edge, mark the way used as most recently used.
--   reset      : clears every valid bit and the LRU bits.
--
--   hit / miss are the compare of the CHECK cycle, held until the next request's CHECK: a
--   latch passes the compare only while latch_way (CHECK) or reset is on. The compare itself
--   is X while a read miss writes the tag and valid cells (their read outputs are then 'Z').
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity cache is
    port (
        clk        : in  std_logic;
        address    : in  std_logic_vector(ADDR_W-1 downto 0);   -- latched CPU address (CA)
        fill       : in  std_logic;   -- read miss: the block comes from memory
        fill_byte  : in  std_logic_vector(1 downto 0);          -- byte of the block being written
        write      : in  std_logic;   -- the write signal
        latch_way  : in  std_logic;
        lru_update : in  std_logic;
        reset      : in  std_logic;
        Vdd        : in  std_logic;
        write_data : in  std_logic_vector(DATA_W-1 downto 0);
        read_data  : out std_logic_vector(DATA_W-1 downto 0);   -- the addressed byte
        hit        : out std_logic;
        miss       : out std_logic;
        way        : out std_logic    -- the way being written / read (for observation)
    );
end entity cache;

architecture structural of cache is
    -- fields of the address
    signal tag, block_offset, byte_offset : std_logic_vector(1 downto 0);
    signal cell_byte_offset               : std_logic_vector(1 downto 0);   -- byte actually selected
    signal block_select, byte_select      : std_logic_vector(3 downto 0);

    -- the two ways
    signal read0, read1                   : std_logic_vector(DATA_W-1 downto 0);
    signal stored_tag0, stored_tag1       : std_logic_vector(TAG_W-1 downto 0);
    signal valid0, valid1, hit0, hit1     : std_logic;
    signal miss0, miss1                   : std_logic;

    -- way selection and replacement
    signal hit_i, hit_way, victim, lru_way, used_way, fill_way : std_logic;
    signal way_sel, way_sel_n, write0, write1               : std_logic;
    signal miss_i, rst_n, hit_d, hit_open, hit_held, hit_n   : std_logic;
begin
    -- ---------------- Address: | tag | block offset | byte offset | ----------------
    tag          <= address(5 downto 4);
    block_offset <= address(3 downto 2);
    byte_offset  <= address(1 downto 0);

    -- read miss: write bytes 0..3 of the block in turn; otherwise the CPU's byte offset
    u_byte_mux : entity work.mux2_n generic map (N => 2)
        port map (a => byte_offset, b => fill_byte, s => fill, y => cell_byte_offset);

    -- ---------------- Decoders (shared by both ways) ----------------
    u_block_dec : entity work.decoder2to4 port map (a => block_offset,     en => Vdd, y => block_select);
    u_byte_dec  : entity work.decoder2to4 port map (a => cell_byte_offset, en => Vdd, y => byte_select);

    -- ---------------- Write signal of each way ----------------
    -- write hit: the way that hit; read miss: the victim kept in fill_way
    u_way_mux : entity work.mux2 port map (a => hit_way, b => fill_way, s => fill, y => way_sel);
    u_way_n   : entity work.not_gate  port map (a => way_sel, y => way_sel_n);
    u_write0  : entity work.and2_gate port map (a => write, b => way_sel_n, y => write0);
    u_write1  : entity work.and2_gate port map (a => write, b => way_sel,   y => write1);

    -- ---------------- The two ways ----------------
    u_way0 : entity work.cache_way
        port map (block_select => block_select, byte_select => byte_select, write => write0, fill => fill,
                  reset => reset, write_data => write_data, tag_in => tag,
                  read_data => read0, tag_out => stored_tag0, valid_out => valid0);
    u_way1 : entity work.cache_way
        port map (block_select => block_select, byte_select => byte_select, write => write1, fill => fill,
                  reset => reset, write_data => write_data, tag_in => tag,
                  read_data => read1, tag_out => stored_tag1, valid_out => valid1);

    -- ---------------- Hit/Miss of each way, way selection ----------------
    u_hit_miss0 : entity work.hit_miss
        port map (tag => tag, stored_tag => stored_tag0, valid => valid0, hit => hit0, miss => miss0);
    u_hit_miss1 : entity work.hit_miss
        port map (tag => tag, stored_tag => stored_tag1, valid => valid1, hit => hit1, miss => miss1);
    u_way_select : entity work.way_select
        port map (hit0 => hit0, hit1 => hit1, valid0 => valid0, valid1 => valid1, lru_way => lru_way,
                  hit => hit_i, miss => miss_i, hit_way => hit_way, victim => victim);

    -- ---------------- Replacement: LRU bits and the way being filled ----------------
    -- the way used by this request: the way that hit, or the victim of a read miss
    u_used : entity work.mux2 port map (a => victim, b => hit_way, s => hit_i, y => used_way);
    u_lru  : entity work.lru
        port map (clk => clk, reset => reset, block_offset => block_offset, update => lru_update,
                  used_way => used_way, lru_way => lru_way);
    u_fill_way : entity work.dff_en port map (d => victim, load => latch_way, clk => clk, q => fill_way);

    -- ---------------- Read data: the byte from the way that hit ----------------
    u_read_mux : entity work.mux2_n generic map (N => DATA_W)
        port map (a => read0, b => read1, s => hit_way, y => read_data);

    -- ---------------- hit / miss, held from the end of CHECK; reset clears them ----------------
    u_rst_n    : entity work.not_gate  port map (a => reset, y => rst_n);
    u_hit_d    : entity work.and2_gate port map (a => hit_i, b => rst_n, y => hit_d);
    u_hit_open : entity work.or2_gate  port map (a => latch_way, b => reset, y => hit_open);
    u_hit_hold : entity work.Dlatch    port map (d => hit_d, clk => hit_open, q => hit_held, qbar => hit_n);

    hit  <= hit_held;
    miss <= hit_n;
    way  <= way_sel;
end architecture structural;
