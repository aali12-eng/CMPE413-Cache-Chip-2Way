-- 5-bit clock cycle counter of a request (negative edge)
--   restart = 1 : count <= 1   (the first negative edge of a request)
--   count   = 1 : count <= count + 1        count = 0 and restart = 0 : count <= 0 (synchronous clear)
--   The state machine counts the clock cycles of every request with it, so after the negative
--   edge where busy goes low it holds the request's length: read hit 2, write hit/miss 3,
--   read miss 19. During a read miss it also times the memory access and the four byte writes.
library ieee;
use ieee.std_logic_1164.all;
use work.cache_pkg.all;

entity counter is
    port (
        count   : in  std_logic;
        restart : in  std_logic;
        clk     : in  std_logic;
        q       : out std_logic_vector(COUNT_W-1 downto 0)
    );
end entity counter;

architecture structural of counter is
    signal q_i, q_n, sum, d, d_c : std_logic_vector(COUNT_W-1 downto 0);
    signal carry                  : std_logic_vector(COUNT_W downto 0);
    signal restart_n              : std_logic;
begin
    carry(0) <= '1';                                      -- add one
    u_rs_n : entity work.not_gate port map (a => restart, y => restart_n);
    g_bit : for i in 0 to COUNT_W-1 generate
        u_ha  : entity work.half_adder port map (a => q_i(i), b => carry(i), sum => sum(i), carry => carry(i+1));
        u_clr : entity work.and2_gate  port map (a => sum(i), b => count, y => d_c(i));
        -- restart: bit 0 is set, the other bits are cleared
        g_b0 : if i = 0 generate
            u_rs : entity work.or2_gate  port map (a => d_c(i), b => restart, y => d(i));
        end generate g_b0;
        g_bn : if i > 0 generate
            u_rs : entity work.and2_gate port map (a => d_c(i), b => restart_n, y => d(i));
        end generate g_bn;
        u_ff  : entity work.dff        port map (d => d(i), clk => clk, q => q_i(i), qbar => q_n(i));
    end generate g_bit;
    q <= q_i;
end architecture structural;
