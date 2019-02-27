library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A 1 bit half adder.

entity half_adder is
  port
  (
    clk         : in  std_logic;
    --
    a_in        : in  std_logic;
    b_in        : in  std_logic;
    --
    result_out  : out std_logic;
    carry_out   : out std_logic
  );
end entity;

architecture rtl of half_adder is

begin

  process(clk) is
  begin
    if rising_edge(clk) then
      result_out  <= a_in xor b_in;
    end if;
  end process;

  carry_out   <= a_in and b_in;

end architecture;