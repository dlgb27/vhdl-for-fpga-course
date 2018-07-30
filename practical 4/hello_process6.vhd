library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A complex logic function: 
--
-- (not a) and b and (d or ((not c) and (not d)))
-- or
-- (not c) and d and (b or (a and (not b)))
--
-- implemented with a case statement.

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
      case switches(3 downto 0) is
        when "0100" =>
          leds(0) <= '1';
        when "0101" => 
          leds(0) <= '1';
        when "0111" => 
          leds(0) <= '1';
        when "1101" =>
          leds(0) <= '1';
        when "0001" =>
          leds(0) <= '1';

        -- when  "0100" | "0101" | "0111" | "1101" | "1001" =>
        when others => 
          leds(0) <= '0';
      end case;
    end if;
  end process;

end architecture;