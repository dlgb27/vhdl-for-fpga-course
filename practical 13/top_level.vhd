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

  write_debounce_i : entity work.debounce
  port map (clk => clk, bit_in => buttons(2), bit_out => fifo_write);

  read_debounce_i : entity work.debounce
  port map (clk => clk, bit_in => buttons(3), bit_out => fifo_read);

  fifo_i : entity work.fifo
  port map 
  (
    clk         => clk,
    reset_in    => buttons(0),
    --
    d_in        => switches(15 downto 0),
    write_in    => fifo_write,
    full_out    => open,
    --
    q_out       => leds(15 downto 0),
    read_in     => fifo_read,
    empty_out   => open
  );

end architecture;