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

  signal pulse, led_r       : std_logic;

begin

  counter_inst : entity work.counter
  generic map
  (
    bits        => 27
  )
  port map 
  (
    clk         => clk,
    --
    pulse_out   => pulse
  );

  led_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if pulse = '1' then
        led_r <= not led_r;
      end if;
    end if;
  end process;

  leds(0) <= led_r;

end architecture;