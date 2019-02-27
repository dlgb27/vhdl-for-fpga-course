library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A complex logic function: 
--
-- (not a) and b and (d or ((not c) and (not d)))
-- or
-- (not c) and d and (b or ((not a) and (not b)))
--
-- implemented using a with-select statement.

entity async_logic is
  port
  (
    switches  : in  std_logic_vector(15 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of async_logic is

begin

  with switches(3 downto 0) select
    leds(0) <=  '1' when "0100",
                '1' when "0101",
                '1' when "0111",
                --'1' when "0101", -- Already covered this case
                '1' when "1101",
                '1' when "0001",
                '0' when others;


end architecture;