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

  full_adder_inst : entity work.full_adder
  port map 
  (
    clk         => clk,
    --
    a_in        => switches(0),
    b_in        => switches(1),
    carry_in    => switches(2),
    --
    result_out  => leds(0),
    carry_out   => leds(1)
  );

end architecture;