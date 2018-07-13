library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is
  port
  (
    a_in        : in std_logic;
    b_in        : in std_logic;
    carry_in    : in std_logic;
    --
    result_out  : out std_logic;
    carry_out   : out std_logic
  );
end entity;

architecture rlt of full_adder is

  signal a_xor_b      : std_logic;

begin

  a_xor_b     <= a_in xor b_in;
  result_out  <= a_xor_b xor carry_in;

  carry_out   <= ((a_in and b_in) or (a_xor_b and carry_in));

end architecture;