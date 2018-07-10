library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity async_mux is
  port
  (
    switches  : in std_logic_vector(15 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rlt of async_mux is

begin

  leds(0) <= switches(1) when switches(0) = '1' else switches(2);

end architecture;