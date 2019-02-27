library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Implement the following logic function:
--
-- (not a) and b and (d or ((not c) and (not d)))
-- or
-- (not c) and d and (b or ((not a) and (not b)))
--
-- where a,b,c,d are the bottom bits of switches respectively.

entity async_logic is
  port
  (
    switches  : in  std_logic_vector(15 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of async_logic is

  signal a, b, c, d   : std_logic;
  signal x, y         : std_logic;
  signal i, j         : std_logic;

begin

  a <= switches(0);
  b <= switches(1);
  c <= switches(2);
  d <= switches(3);

  x <= d or ((not c) and (not d));

  y <= b or ((not a) and (not b));

  i <= (not a) and b and x;

  j <= (not c) and d and y;

  leds(0) <= i or j;

end architecture;