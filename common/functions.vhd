library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package functions is
  
  function log_ceil(value : integer) return integer;

end package;

package body functions is

  function log_ceil(value : integer) return integer is
    variable ret : integer := 0;
  begin
    while 2**ret < value loop
      ret := ret + 1;
    end loop;
    return ret;
  end function;

end package body;