-- Helpers for the self-checking testbenches (VHDL-93: no to_string in the standard library)
library ieee;
use ieee.std_logic_1164.all;

package tb_pkg is
    function str (v : std_logic_vector) return string;
    function str (b : std_logic) return string;
    function str (n : integer) return string;
end package tb_pkg;

package body tb_pkg is
    function str (b : std_logic) return string is
        constant img : string(1 to 3) := std_logic'image(b);   -- e.g. '1'
    begin
        return img(2 to 2);
    end function;

    function str (v : std_logic_vector) return string is
        variable s : string(1 to v'length);
        variable k : positive := 1;
    begin
        for i in v'range loop
            s(k to k) := str(v(i));
            k := k + 1;
        end loop;
        return s;
    end function;

    function str (n : integer) return string is
    begin
        return integer'image(n);
    end function;
end package body tb_pkg;
