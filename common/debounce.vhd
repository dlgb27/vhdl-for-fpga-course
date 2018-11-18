library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
  port
  (
    clk     : in std_logic;
    --
    bit_in  : in std_logic;
    --
    bit_out : out std_logic
  );
end entity;

architecture rlt of debounce is

  signal count_u      : unsigned(16 downto 0);
  signal count_ur     : unsigned(15 downto 0);
  signal bit_in_r     : std_logic;

begin

  count_u <= ('0' & count_ur) + 1;

  process(clk) is
  begin
    if rising_edge(clk) then
      bit_in_r <= bit_in;

      if (count_u(count_u'high) = '1') then
        bit_out <= bit_in;
      end if;

      count_ur <= count_u(count_ur'range);

      if (bit_in_r /= bit_in) then
        count_ur <= (others => '0');
      end if;

    end if;
  end process;

end architecture;