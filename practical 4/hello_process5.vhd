library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A complex logic function: 
--
-- (not a) and b and (d or ((not c) and (not d)))
-- or
-- (not c) and d and (b or (a and (not b)))
--
-- with a flip flop.

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

architecture rtl of hello_process is

  signal a, b, c, d   : std_logic;
  signal x, y         : std_logic;
  signal i, j         : std_logic;

begin

  a <= switches(0);
  b <= switches(1);
  c <= switches(2);
  d <= switches(3);

  x <= d or ((not c) and (not d));

  y <= b or (a and (not b));

  i <= (not a) and b and x;

  j <= (not c) and d and y;

  my_process : process(buttons(0)) is
  begin
    if (rising_edge(buttons(0))) then
      leds(0) <= i or j;
    end if;
  end process;

end architecture;