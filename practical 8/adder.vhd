library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A generic width adder with potential overflow.

entity adder is
  generic
  (
    bits        : natural
  );
  port
  (
    clk         : in  std_logic;
    --
    a_in        : in  std_logic_vector(bits-1 downto 0);
    b_in        : in  std_logic_vector(bits-1 downto 0);
    --
    result_out  : out std_logic_vector(bits-1 downto 0)
  );
end entity;

architecture rtl of adder is

  signal a_u, b_u : unsigned(bits-1 downto 0);
  signal sum_u    : unsigned(bits-1 downto 0);

begin

  process(clk) is
  begin
    if rising_edge(clk) then
      a_u <= unsigned(a_in);
      b_u <= unsigned(b_in);

      sum_u <= a_u + b_u;
    end if;
  end process;

  result_out <= std_logic_vector(sum_u);


end architecture;