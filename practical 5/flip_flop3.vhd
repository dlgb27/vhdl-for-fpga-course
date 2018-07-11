library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flip_flop is
  port
  (
    switches  : in std_logic_vector(15 downto 0);
    --
    buttons   : in std_logic_vector(4 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rlt of flip_flop is

  signal reset, clk       : std_logic;
  signal d, q             : std_logic;

begin

  reset   <= buttons(0);
  clk     <= buttons(1);

  d       <= switches(0);
  leds(0) <= q;

  flip_flop : process(clk, reset) is
  begin
    if (reset = '1') then
      q <= '0';
    elsif rising_edge(clk) then
      q <= d;
    end if;
  end process;

end architecture;