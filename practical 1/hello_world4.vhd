library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hello_world is
  port
  (
    switches  : in std_logic_vector(1 downto 0);
    --
    leds      : out std_logic_vector(1 downto 0)
  );
end entity;

architecture rlt of hello_world is

begin

  -- The LED's come on when their oposit switch is closed.
  leds(0) <= switches(1);
  leds(1) <= switches(0);
  
end architecture;