library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A very simple example with two flip flops to provide a path that can be timing analysed.

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

  signal reset            : std_logic;
  signal d, q_r, q_rr     : std_logic;

begin

  reset   <= buttons(0);
  d       <= switches(0);
  leds(0) <= q_rr;

  flip_flop : process(clk) is
  begin
    if rising_edge(clk) then
      q_r  <= d;
      q_rr <= q_r;
    end if;
  end process;

end architecture;