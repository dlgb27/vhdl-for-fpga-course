library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity b2b_if_tb is
end entity;

architecture rtl of b2b_if_tb is

  constant clk_period : time := 10 ns;

  signal clk          : std_logic;
  signal reset        : std_logic;


  signal data         : std_logic_vector(1 downto 0);
  signal data_valid   : std_logic;

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
    data_valid <= '0';
    reset <= '1';
    wait for 100 ns;
    wait until rising_edge(clk);
    reset <= '0';


    wait for 200ns;
    wait until rising_edge(clk);
    data        <= "01";
    data_valid  <= '1';
    wait until rising_edge(clk);
    data_valid  <= '0';

    wait;
  end process;

  uut : entity work.b2b_if
  generic map
  (
    bits => 2
  )
  port map
  (
    clk_in		              => clk,
    --
    data_in                 => data,
    data_valid_in           => data_valid,
    data_out                => open,
    data_out_valid          => open,
    ready_for_new_data_out  => open,
    --
    CLK_PIN_OUT             => clk_pins,
    DATA_PINS_OUT           => data_pins,
    CLK_PIN_IN              => clk_pins,
    DATA_PINS_IN            => data_pins
  );

end architecture;