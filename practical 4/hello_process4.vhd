library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hello_process is
  port
  (
    switches  : in  std_logic_vector(15 downto 0);
    --
    buttons   : in  std_logic_vector(4 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rlt of hello_process is

begin

  my_process : process(buttons(0)) is
  begin
    if (rising_edge(buttons(0))) then
      leds <= switches;
    end if;
  end process;

end architecture;