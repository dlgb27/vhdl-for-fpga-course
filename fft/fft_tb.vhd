library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fft_tb is
end entity;

architecture rtl of fft_tb is

  constant clk_period : time := 10 ns;

  signal clk          : std_logic;
  signal clk_enable   : std_logic := '1';
  signal reset        : std_logic;

  signal switches     : std_logic_vector(15 downto 0);
  signal buttons      : std_logic_vector(4 downto 0);
  signal leds         : std_logic_vector(15 downto 0);

begin

  clk_process: process is
  begin
    if clk_enable = '1' then
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
      clk <= '0';
    else
      wait;
    end if;
  end process;

  stimulus_procsss: process is
  begin
    reset <= '1';
    wait for 100 ns;
    wait until rising_edge(clk);
    reset <= '0';

    switches <= "1111111111111111";
    for i in 0 to 100 loop
      wait until rising_edge(clk);
    end loop;

    switches <= "0000000000000000";
    for i in 0 to 100 loop
      wait until rising_edge(clk);
    end loop;

    switches <= "1111111100000000";
    for i in 0 to 100 loop
      wait until rising_edge(clk);
    end loop;

    switches <= "1111000011110000";
    for i in 0 to 100 loop
      wait until rising_edge(clk);
    end loop;

    switches <= "1100110011001100";
    for i in 0 to 100 loop
      wait until rising_edge(clk);
    end loop;

    switches <= "1010101010101010";
    for i in 0 to 300 loop
      wait until rising_edge(clk);
    end loop;

    clk_enable <= '0';

    wait;
  end process;

  buttons(0) <= reset;

  uut : entity work.toplevel
  port map
  (
    clk       => clk,
    --  
    switches  => switches,
    --
    buttons   => buttons,
    --
    leds      => leds
  );

end architecture;