-- N-bit 4:1 multiplexer: tree of three mux2_n
library ieee;
use ieee.std_logic_1164.all;

entity mux4_n is
    generic (N : positive := 8);
    port (
        d0, d1, d2, d3 : in  std_logic_vector(N-1 downto 0);
        s              : in  std_logic_vector(1 downto 0);
        y              : out std_logic_vector(N-1 downto 0)
    );
end entity mux4_n;

architecture structural of mux4_n is
    signal m01, m23 : std_logic_vector(N-1 downto 0);
begin
    u_01 : entity work.mux2_n generic map (N => N) port map (a => d0,  b => d1,  s => s(0), y => m01);
    u_23 : entity work.mux2_n generic map (N => N) port map (a => d2,  b => d3,  s => s(0), y => m23);
    u_y  : entity work.mux2_n generic map (N => N) port map (a => m01, b => m23, s => s(1), y => y);
end architecture structural;
