library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Very simple example of an asynchronous process.

entity hello_process is
  port
  (
    switches  : in  std_logic_vector(15 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of hello_process is

begin

  -- In this example, the process does nothing for us. Might as well no be there!
  my_process : process(switches) is
  begin

    leds <= switches;

  end process;

end architecture;