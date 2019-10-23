library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity end_to_end_tb is
end entity;

architecture rtl of end_to_end_tb is

  constant clk_period      : time := 10 ns;

  signal clk               : std_logic;
  signal reset             : std_logic;
  signal switches          : std_logic_vector(15 downto 0);
  signal leds              : std_logic_vector(15 downto 0);

  signal start_encryption     : std_logic;

  signal serial_switch        : std_logic;
  signal serial_switch_valid  : std_logic;
  signal serial_switch_first  : std_logic;

  signal data_to_b2b          : std_logic_vector(1 downto 0);
  signal data_to_b2b_valid    : std_logic;
  signal b2b_ready            : std_logic;

  signal data_from_b2b        : std_logic_vector(1 downto 0);
  signal data_from_b2b_valid  : std_logic;

  signal decrypted_bit        : std_logic;
  signal decrypted_bit_valid  : std_logic;
  signal decrypted_bit_first  : std_logic;

  signal leds_buf             : std_logic_vector(15 downto 0);
  signal leds_buf_valid       : std_logic;

  signal pins : std_logic_vector(2 downto 0);

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
    switches         <= x"1234";
    start_encryption <= '0';

    reset <= '1';
    wait for 100 ns;
    wait until rising_edge(clk);
    reset <= '0';

    wait for 200ns;
    wait until rising_edge(clk);
    start_encryption <= '1';
    wait until rising_edge(clk);
    start_encryption <= '0';

    wait;
  end process;


  serialiser_inst : entity work.serialiser
  port map
  (
    clk              => clk,
    --  
    data_in          => switches,
    data_in_valid    => start_encryption,
    --
    data_out         => serial_switch,
    data_out_valid   => serial_switch_valid,
    data_out_first   => serial_switch_first
  );

  stream_cipher_inst1 : entity work.stream_cipher
  port map
  (
    clk             => clk,
    reset           => reset,
    --
    data_in         => serial_switch,
    data_in_valid   => serial_switch_valid,
    data_in_first   => serial_switch_first,
    --
    data_out        => data_to_b2b(0),
    data_out_valid  => data_to_b2b_valid,
    data_out_first  => data_to_b2b(1)
  );

  b2b_if_inst : entity work.b2b_if
  generic map
  (
    bits                    => data_to_b2b'length
  )
  port map
  (
    clk_in                  => clk,
    reset_in                => reset,
    --
    data_in                 => data_to_b2b,
    data_valid_in           => data_to_b2b_valid,
    data_out                => data_from_b2b,
    data_out_valid          => data_from_b2b_valid,
    ready_for_new_data_out  => b2b_ready,
    --
    CLK_PIN_OUT             => pins(0),
    DATA_PINS_OUT           => pins(2 downto 1),
    CLK_PIN_IN              => pins(0),
    DATA_PINS_IN            => pins(2 downto 1)
  );

  stream_cipher_inst2 : entity work.stream_cipher
  port map
  (
    clk             => clk,
    reset           => reset,
    --
    data_in         => data_from_b2b(0),
    data_in_valid   => data_from_b2b_valid,
    data_in_first   => data_from_b2b(1),
    --
    data_out        => decrypted_bit,
    data_out_valid  => decrypted_bit_valid,
    data_out_first  => decrypted_bit_first
  );

  paralleliser_inst : entity work.paralleliser
  port map
  (
    clk            => clk,
    --  
    data_in        => decrypted_bit,
    data_in_valid  => decrypted_bit_valid,
    data_in_frame  => decrypted_bit_first,
    --
    data_out       => leds_buf,
    data_out_valid => leds_buf_valid
  );

  process(clk) is
  begin
    if rising_edge(clk) then
      if leds_buf_valid = '1' then
        leds <= leds_buf;
      end if;
    end if;
  end process;


end architecture;