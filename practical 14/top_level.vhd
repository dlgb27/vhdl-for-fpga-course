library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
  port
  (
    clk       : in  std_logic;
    --  
    switches  : in  std_logic_vector(15 downto 0);
    --
    buttons   : in  std_logic_vector(4 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of toplevel is

  signal fifo_write, fifo_read    : std_logic;

begin

  fifo_i : entity work.combination_lock
  port map 
  (
    clk         => clk,
    --
    clear_in    => buttons(0),
    buttons_in  => buttons(4 downto 1),
    --
    locked_out  => leds(0)
  );

end architecture;