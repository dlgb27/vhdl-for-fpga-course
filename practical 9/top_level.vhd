library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
  port
  (
    clk       : in std_logic;
    --  
    switches  : in std_logic_vector(15 downto 0);
    --
    buttons   : in std_logic_vector(4 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rlt of toplevel is

begin

  counter_inst : entity work.counter
  generic map
  (
    bits        => 8
  )
  port map 
  (
    clk         => clk,
    --
    pulse_out   => leds(0)
  );

end architecture;