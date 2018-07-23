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

  rom_i : entity work.ram
  generic map
  (
    a_bits      => 8,
    d_bits      => 8
  )
  port map 
  (
    clk         => clk,
    --
    d_in        => switches(7 downto 0),
    wr_a_in     => switches(15 downto 8),
    wr_en_in    => buttons(0),
    --
    q_out       => leds(7 downto 0),
    rd_a_in     => switches(15 downto 8)
  );

end architecture;