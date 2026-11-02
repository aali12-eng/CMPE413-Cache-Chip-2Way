-- One cache block: valid bit, 2-bit tag and 4 data bytes ("4 words/block"), all cache cells
--   Data byte i is enabled by block_select and byte_select(i) (the decoded byte offset).
--   The tag and valid cells are enabled by block_select; reset also enables the valid cell
--   so that reset clears every valid bit at once.
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity cache_block is
    port (
        block_select : in  std_logic;
        byte_select  : in  std_logic_vector(NUM_BYTES-1 downto 0);   -- one-hot byte offset
        reset        : in  std_logic;
        data_rd_wrn  : in  std_logic;   -- 0 while the write signal is on
        tag_rd_wrn   : in  std_logic;   -- 0 while writing a block from memory (read miss)
        valid_rd_wrn : in  std_logic;   -- 0 while writing a block from memory, or reset
        write_data   : in  std_logic_vector(DATA_W-1 downto 0);
        tag_in       : in  std_logic_vector(TAG_W-1 downto 0);
        valid_in     : in  std_logic;
        read_data    : out std_logic_vector(DATA_W-1 downto 0);      -- shared buses ('Z' when
        tag_out      : out std_logic_vector(TAG_W-1 downto 0);       --  this block is not
        valid_out    : out std_logic                                 --  selected)
    );
end entity cache_block;

architecture structural of cache_block is
    signal byte_enable : std_logic_vector(NUM_BYTES-1 downto 0);
    signal valid_enable : std_logic;
begin
    -- ---------------- Data bytes ----------------
    g_byte : for i in 0 to NUM_BYTES-1 generate
        u_en   : entity work.and2_gate port map (a => block_select, b => byte_select(i), y => byte_enable(i));
        u_byte : entity work.cache_byte
            port map (write_data => write_data, chip_enable => byte_enable(i), rd_wrn => data_rd_wrn,
                      read_data => read_data);
    end generate g_byte;

    -- ---------------- Tag ----------------
    g_tag : for i in 0 to TAG_W-1 generate
        u_tag : entity work.cache_cell
            port map (write_data => tag_in(i), chip_enable => block_select, rd_wrn => tag_rd_wrn,
                      read_data => tag_out(i));
    end generate g_tag;

    -- ---------------- Valid ----------------
    u_valid_en : entity work.or2_gate port map (a => block_select, b => reset, y => valid_enable);
    u_valid    : entity work.cache_cell
        port map (write_data => valid_in, chip_enable => valid_enable, rd_wrn => valid_rd_wrn,
                  read_data => valid_out);
end architecture structural;
