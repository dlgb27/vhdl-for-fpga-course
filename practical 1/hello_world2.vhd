library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This is a really simple VHDL file

entity hello_world is
  port
  (
    sw1   : in  std_logic;
    sw2   : in  std_logic;
    --
    led1  : out std_logic;
    led2  : out std_logic
  );
end entity;

architecture rtl of hello_world is

begin

  -- The LED's come on when their respetive switch is closed.
  led1 <= sw1;
  led2 <= sw2;
  
end architecture;