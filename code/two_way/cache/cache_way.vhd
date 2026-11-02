-- One way of the two-way cache: 4 cache blocks (16 bytes)
--   block_select / byte_select come from the cache's shared decoders (one-hot block offset
--   and byte offset of the address).
--   write = 1 writes write_data into the selected byte of this way; during a read miss
--   (fill = 1) it also stores the tag and sets the valid bit. reset clears every valid bit.
--   The selected byte, and the tag and valid bit of the selected block, are always read, except
--   during a read miss (fill = 1): latches then hold them at their values from before the fill,
--   so they do not show the bytes being written, nor the 'Z' of the tag / valid / data cells
--   while they are written, until the whole block is in.
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity cache_way is
    port (
        block_select : in  std_logic_vector(NUM_BLOCKS-1 downto 0);
        byte_select  : in  std_logic_vector(NUM_BYTES-1 downto 0);
        write        : in  std_logic;   -- write signal of this way
        fill         : in  std_logic;   -- read miss: the block comes from memory
        reset        : in  std_logic;
        write_data   : in  std_logic_vector(DATA_W-1 downto 0);
        tag_in       : in  std_logic_vector(TAG_W-1 downto 0);
        read_data    : out std_logic_vector(DATA_W-1 downto 0);
        tag_out      : out std_logic_vector(TAG_W-1 downto 0);   -- tag of the selected block
        valid_out    : out std_logic                             -- valid bit of the selected block
    );
end entity cache_way;

architecture structural of cache_way is
    signal tag_write, valid_write                 : std_logic;
    signal data_rd_wrn, tag_rd_wrn, valid_rd_wrn   : std_logic;
    signal valid_in                                : std_logic;
    -- the cells' outputs, and the latches that pass them while fill = 0
    signal data_c, data_n                          : std_logic_vector(DATA_W-1 downto 0);
    signal tag_c, tag_n                            : std_logic_vector(TAG_W-1 downto 0);
    signal valid_c, valid_n, look                  : std_logic;
begin
    -- ---------------- RD/WR of the cells ----------------
    -- data: written whenever the write signal of this way is on
    u_data_rw  : entity work.not_gate  port map (a => write, y => data_rd_wrn);
    -- tag and valid: written with the data bytes of a read miss
    u_tag_w    : entity work.and2_gate port map (a => write, b => fill, y => tag_write);
    u_tag_rw   : entity work.not_gate  port map (a => tag_write, y => tag_rd_wrn);
    -- valid: also written (to 0) by reset. The value written is fill (1 during a read miss,
    -- 0 otherwise), not "not reset", which would rise before the valid cell's write enable
    -- falls when reset ends and the latch would capture a 1 (a hold-time race).
    u_valid_w  : entity work.or2_gate  port map (a => tag_write, b => reset, y => valid_write);
    u_valid_rw : entity work.not_gate  port map (a => valid_write, y => valid_rd_wrn);
    valid_in <= fill;

    -- ---------------- Cache blocks ----------------
    g_block : for i in 0 to NUM_BLOCKS-1 generate
        u_block : entity work.cache_block
            port map (block_select => block_select(i), byte_select => byte_select, reset => reset,
                      data_rd_wrn => data_rd_wrn, tag_rd_wrn => tag_rd_wrn, valid_rd_wrn => valid_rd_wrn,
                      write_data => write_data, tag_in => tag_in, valid_in => valid_in,
                      read_data => data_c, tag_out => tag_c, valid_out => valid_c);
    end generate g_block;

    -- ---------------- Outputs, held during a read miss ----------------
    u_look : entity work.not_gate port map (a => fill, y => look);
    g_data : for i in 0 to DATA_W-1 generate
        u_data_hold : entity work.Dlatch port map (d => data_c(i), clk => look, q => read_data(i), qbar => data_n(i));
    end generate g_data;
    g_tag : for i in 0 to TAG_W-1 generate
        u_tag_hold : entity work.Dlatch port map (d => tag_c(i), clk => look, q => tag_out(i), qbar => tag_n(i));
    end generate g_tag;
    u_valid_hold : entity work.Dlatch port map (d => valid_c, clk => look, q => valid_out, qbar => valid_n);
end architecture structural;
