library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce_tb is
end entity;

architecture rtl of debounce_tb is

  constant clk_period : time := 10 ns;

  signal clk            : std_logic;
  signal clk_enable     : std_logic := '1';
  signal reset          : std_logic;

  signal bit_in         : std_logic;

begin

  clk_process: process is
  begin
    if (clk_enable = '1') then
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
      clk <= '0';
    else
      wait;
    end if;
  end process;

  stimulus_process: process is
  begin
    bit_in <= '0';
    reset <= '1';
    wait for 100 ns;
    wait until rising_edge(clk);
    reset <= '0';

    wait until rising_edge(clk);
    bit_in <= '0';
    wait until rising_edge(clk);
    bit_in <= '1';
    wait until rising_edge(clk);
    bit_in <= '1';
    wait until rising_edge(clk);
    bit_in <= '0';
    wait until rising_edge(clk);
    bit_in <= '0';
    wait until rising_edge(clk);
    bit_in <= '1';
    wait until rising_edge(clk);
    bit_in <= '1';
    wait until rising_edge(clk);
    bit_in <= '1';
    wait until rising_edge(clk);
    bit_in <= '0';
    wait until rising_edge(clk);
    bit_in <= '0';
    wait until rising_edge(clk);
    bit_in <= '1';
    wait until rising_edge(clk);
    bit_in <= '1';

    wait for 1000 ns;

    wait until rising_edge(clk);
    bit_in <= '0';
    wait until rising_edge(clk);
    bit_in <= '1';
    wait until rising_edge(clk);
    bit_in <= '0';

    wait for 1000 ns;
    wait for 1000 ns;
    wait for 1000 ns;

    clk_enable <= '0';
    wait;
  end process;

  uut : entity work.debounce
  port map 
  (
    clk         => clk,
    --
    bit_in      => bit_in,
    bit_out     => open
  );

end architecture;