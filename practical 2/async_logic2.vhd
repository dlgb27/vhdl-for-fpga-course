library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity async_logic is
  port
  (
    switches  : in std_logic_vector(15 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rlt of async_logic is

  signal a : std_logic_vector(15 downto 0);
  signal b : std_logic;

begin

  a       <= not switches;
  leds(0) <= a(0) xor a(1);

end architecture;