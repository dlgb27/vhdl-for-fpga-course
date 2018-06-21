library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hello_world is
  port
  (
    sw1   : in std_logic;
    --
    led1  : out std_logic
  );
end entity;

architecture rlt of hello_world is

begin

  -- The LED comes on when the switch is closed.
  led1 <= sw1;
  
end architecture;