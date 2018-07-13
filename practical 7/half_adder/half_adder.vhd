library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity half_adder is
  port
  (
    a_in        : in std_logic;
    b_in        : in std_logic;
    --
    result_out  : out std_logic;
    carry_out   : out std_logic
  );
end entity;

architecture rlt of half_adder is

begin

  result_out  <= a_in xor b_in;

  carry_out   <= a_in and b_in;

end architecture;