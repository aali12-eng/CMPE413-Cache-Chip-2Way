-- N-input AND (reduction): chain of 2-input AND gates, y = a(0) and a(1) and ... a(N-1)
library ieee;
use ieee.std_logic_1164.all;

entity and_reduce_n is
    generic (N : positive := 4);
    port (
        a : in  std_logic_vector(N-1 downto 0);
        y : out std_logic
    );
end entity and_reduce_n;

architecture structural of and_reduce_n is
    signal chain : std_logic_vector(N-1 downto 0);
begin
    chain(0) <= a(0);
    g_and : for i in 1 to N-1 generate
        u_and : entity work.and2_gate port map (a => chain(i-1), b => a(i), y => chain(i));
    end generate g_and;
    y <= chain(N-1);
end architecture structural;
