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

  signal a_r, b_r : std_logic_vector(7 downto 0);
  signal result   : std_logic_vector(15 downto 0);
begin

  io_proc : process(clk) is
  begin
    if rising_edge(clk) then
      a_r <= switches(7 downto 0);
      b_r <= switches(15 downto 8);

      leds <= result;
    end if;
  end process;

  multiplier_inst : entity work.multiplier
  generic map
  (
    bits        => 8
  )
  port map 
  (
    clk         => clk,
    --
    a_in        => a_r,
    b_in        => b_r,
    --
    result_out  => result
  );

end architecture;