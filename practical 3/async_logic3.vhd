library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity async_logic is
  port
  (
    switches  : in  std_logic_vector(15 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rlt of async_logic is

begin

  with switches(3 downto 0) select
    leds(0) <=  '1' when "0100",
                '1' when "0101",
                '1' when "0111",
                --'1' when "0101", -- Already covered this case
                '1' when "1101",
                '1' when "1001",
                '0' when others;


end architecture;