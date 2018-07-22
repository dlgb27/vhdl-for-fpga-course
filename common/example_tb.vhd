library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity example_tb is
end entity;

architecture rlt of example_tb is

  constant clk_period : time := 10 ns;

  signal clk          : std_logic;
  signal reset        : std_logic;

begin

  clk_process: process is
  begin
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
  end process;

  stimulus_procsss: process is
  begin
    reset <= '1';
    wait for 100 ns;
    wait until rising_edge(clk);
    reset <= '0';

    wait;
  end process;

end architecture;