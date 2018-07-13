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

  signal set, reset, clk  : std_logic;
  signal d, q_r           : std_logic;

begin

  set     <= buttons(0);
  reset   <= buttons(1);
  clk     <= buttons(2);

  d       <= switches(0);
  leds(0) <= q_r;

  flip_flop_proc : process(clk) is
  begin
    if rising_edge(clk) then
      q_r <= d;

      if (set = '1') then
        q_r <= '1';
      end if;
      if (reset = '1') then
        q_r <= '0';
      end if;
    end if;
  end process;

end architecture;