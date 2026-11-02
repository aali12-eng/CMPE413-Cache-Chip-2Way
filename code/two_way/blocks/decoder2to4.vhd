-- 2-to-4 decoder with enable: y(i) = en and (a = i)
library ieee;
use ieee.std_logic_1164.all;

entity decoder2to4 is
    port (
        a  : in  std_logic_vector(1 downto 0);
        en : in  std_logic;
        y  : out std_logic_vector(3 downto 0)   -- one-hot
    );
end entity decoder2to4;

architecture structural of decoder2to4 is
    signal a_n : std_logic_vector(1 downto 0);
begin
    u_inv0 : entity work.not_gate port map (a => a(0), y => a_n(0));
    u_inv1 : entity work.not_gate port map (a => a(1), y => a_n(1));

    u_y0 : entity work.and3_gate port map (a => en, b => a_n(1), c => a_n(0), y => y(0));
    u_y1 : entity work.and3_gate port map (a => en, b => a_n(1), c => a(0),   y => y(1));
    u_y2 : entity work.and3_gate port map (a => en, b => a(1),   c => a_n(0), y => y(2));
    u_y3 : entity work.and3_gate port map (a => en, b => a(1),   c => a(0),   y => y(3));
end architecture structural;
