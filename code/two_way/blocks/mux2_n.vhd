-- N-bit 2:1 multiplexer: one mux2 per bit
library ieee;
use ieee.std_logic_1164.all;

entity mux2_n is
    generic (N : positive := 8);
    port (
        a, b : in  std_logic_vector(N-1 downto 0);   -- a when s = 0, b when s = 1
        s    : in  std_logic;
        y    : out std_logic_vector(N-1 downto 0)
    );
end entity mux2_n;

architecture structural of mux2_n is
begin
    g_bit : for i in 0 to N-1 generate
        u_mux : entity work.mux2 port map (a => a(i), b => b(i), s => s, y => y(i));
    end generate g_bit;
end architecture structural;
