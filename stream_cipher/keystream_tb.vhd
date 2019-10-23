library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keystream_tb is
end entity;

architecture rtl of keystream_tb is

  constant clk_period : time := 10 ns;

  signal clk          : std_logic;
  signal reset        : std_logic;

  signal ce           : std_logic;
  signal keystream_bit_out : std_logic;

  signal data_pins    : std_logic_vector(1 downto 0);
  signal clk_pins     : std_logic;
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
    ce <= '0';
    reset <= '1';
    wait for 100 ns;
    wait until rising_edge(clk);
    reset <= '0';


    wait for 200ns;
    for i in 0 to 32 loop
      wait until rising_edge(clk);
      ce <= '1';
      wait until rising_edge(clk);
      ce <= '0';
    end loop;

    wait;
  end process;

  lfsr1 : entity work.keystream
  port map
  (
    clk     => clk,
    reset   => reset,
    --
    ce      => ce,
    bit_out => keystream_bit_out
  );


end architecture;