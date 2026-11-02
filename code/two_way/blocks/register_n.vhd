-- N-bit register with load (negative edge): one dff_en per bit
--   Used for the CPU address / data / read_write input registers and the output register.
library ieee;
use ieee.std_logic_1164.all;

entity register_n is
    generic (N : positive := 8);
    port (
        d    : in  std_logic_vector(N-1 downto 0);
        load : in  std_logic;
        clk  : in  std_logic;
        q    : out std_logic_vector(N-1 downto 0)
    );
end entity register_n;

architecture structural of register_n is
begin
    g_bit : for i in 0 to N-1 generate
        u_bit : entity work.dff_en port map (d => d(i), load => load, clk => clk, q => q(i));
    end generate g_bit;
end architecture structural;
