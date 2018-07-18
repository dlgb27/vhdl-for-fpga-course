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

  adder_inst : entity work.adder
  generic map
  (
    bits        => 8
  )
  port map 
  (
    clk         => clk,
    --
    a_in        => switches(7 downto 0),
    b_in        => switches(15 downto 8),
    --
    result_out  => leds(7 downto 0)
  );

end architecture;