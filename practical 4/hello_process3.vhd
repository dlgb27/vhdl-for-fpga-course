library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hello_process is
  port
  (
    switches  : in std_logic_vector(15 downto 0);
    --
    buttons   : in std_logic_vector(4 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rlt of hello_process is

begin

  my_process : process(switches, buttons(0)) is
  begin

    leds <= (others => '0');

    if (buttons(0) = '1') then
      leds <= switches;
    end if;

  end process;

end architecture;