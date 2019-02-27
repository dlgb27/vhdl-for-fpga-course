library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A simple logic function

entity async_logic is
  port
  (
    switches  : in  std_logic_vector(15 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of async_logic is

  signal a : std_logic;
  signal b : std_logic;

begin

  a <= (not switches(0)) and switches(1);
  b <= (not switches(2)) and switches(3);

  leds(0) <= a or b;

end architecture;