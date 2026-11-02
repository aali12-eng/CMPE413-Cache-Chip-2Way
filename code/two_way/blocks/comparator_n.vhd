-- N-bit equality comparator (tag compare): one XNOR per bit + AND reduction
library ieee;
use ieee.std_logic_1164.all;

entity comparator_n is
    generic (N : positive := 5);
    port (
        a, b : in  std_logic_vector(N-1 downto 0);
        eq   : out std_logic                       -- 1 when a = b
    );
end entity comparator_n;

architecture structural of comparator_n is
    signal same : std_logic_vector(N-1 downto 0);
begin
    g_bit : for i in 0 to N-1 generate
        u_xnor : entity work.xnor2_gate port map (a => a(i), b => b(i), y => same(i));
    end generate g_bit;

    u_and : entity work.and_reduce_n generic map (N => N) port map (a => same, y => eq);
end architecture structural;
