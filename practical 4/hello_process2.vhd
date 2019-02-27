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

  -- Now we see the delayed assignment that occurs in processes.
  my_process : process(switches) is
  begin

    leds <= (others => '0');
    leds <= switches;

  end process;

end architecture;