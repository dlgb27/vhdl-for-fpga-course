library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity b2b_if_tb is
end entity;

architecture rtl of b2b_if_tb is

  constant clk_period : time := 10 ns;

  signal clk          : std_logic;
  signal reset        : std_logic;

  signal start_transfer       : std_logic;
  signal switches             : std_logic_vector(15 downto 0);

  signal data_to_b2b          : std_logic_vector(1 downto 0);
  signal data_to_b2b_valid    : std_logic;
  signal b2b_ready            : std_logic;

  signal data_from_b2b        : std_logic_vector(1 downto 0);
  signal data_from_b2b_valid  : std_logic;

  signal leds_buf             : std_logic_vector(15 downto 0);
  signal leds_buf_valid       : std_logic;

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
    start_transfer <= '0';
    reset <= '1';
    wait for 100 ns;
    wait until rising_edge(clk);
    reset <= '0';


    wait for 200ns;
    wait until rising_edge(clk);
    switches          <= "1101101101101101";
    start_transfer  <= '1';
    wait until rising_edge(clk);
    start_transfer  <= '0';

    wait;
  end process;

  serialiser_inst : entity work.serialiser
  port map
  (
    clk              => clk,
    --  
    data_in          => switches,
    data_in_valid    => start_transfer,
    --
    data_out         => data_to_b2b(0),
    data_out_valid   => data_to_b2b_valid,
    data_out_first   => data_to_b2b(1),
    data_out_request => b2b_ready
  );

  b2b_if_inst : entity work.b2b_if
  generic map
  (
    bits                    => data_to_b2b'length
  )
  port map
  (
    clk_in		              => clk,
    --
    data_in                 => data_to_b2b,
    data_valid_in           => data_to_b2b_valid,
    data_out                => data_from_b2b,
    data_out_valid          => data_from_b2b_valid,
    ready_for_new_data_out  => b2b_ready,
    --
    CLK_PIN_OUT             => clk_pins,
    DATA_PINS_OUT           => data_pins,
    CLK_PIN_IN              => clk_pins,
    DATA_PINS_IN            => data_pins
  );

  paralleliser_inst : entity work.paralleliser
  port map
  (
    clk            => clk,
    --  
    data_in        => data_from_b2b(0),
    data_in_valid  => data_from_b2b_valid,
    data_in_frame  => data_from_b2b(1),
    --
    data_out       => leds_buf,
    data_out_valid => leds_buf_valid
  );

end architecture;