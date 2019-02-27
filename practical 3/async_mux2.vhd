library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A simple multiplexer

entity async_mux is
  port
  (
    switches  : in  std_logic_vector(15 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of async_mux is

begin

  with switches(0) select
    leds(0) <=  switches(1) when '1',
                switches(2) when '0',
                '0' when others;

end architecture;