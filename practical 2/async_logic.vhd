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

begin

  leds(0) <= switches(0) xor switches(1);

end architecture;