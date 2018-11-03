library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
  port
  (
    clk     : in std_logic;
    --
    bit_in  : in std_logic;
    --
    bit_out : out std_logic
  );
end entity;

architecture rlt of debounce is

  signal sr   : std_logic_vector(9 downto 0) := (others => '0');

begin

  process(clk) is
  begin
    if rising_edge(clk) then
      sr <= sr(sr'high-1 downto 0) & bit_in;
    end if;
  end process;

  bit_out <= '1' when sr = (sr'range => '1') else '0';

end architecture;