library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stream_cipher_tb is
end entity;

architecture rtl of stream_cipher_tb is

  constant clk_period      : time := 10 ns;

  signal clk               : std_logic;
  signal reset             : std_logic;

  signal bit_in_valid : std_logic;
  signal bit_in_first : std_logic;
  signal bit_in       : std_logic;

  signal encrypted_bit_out_valid : std_logic;
  signal encrypted_bit_out_first : std_logic;
  signal encrypted_bit_out       : std_logic;

  signal decrypted_bit_out_valid : std_logic;
  signal decrypted_bit_out_first : std_logic;
  signal decrypted_bit_out       : std_logic;

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
    bit_in_first <= '0';
    bit_in_valid <= '0';
    bit_in <= '0';

    reset <= '1';
    wait for 100 ns;
    wait until rising_edge(clk);
    reset <= '0';

    wait for 200ns;
    wait until rising_edge(clk);
    bit_in_first <= '1';
    bit_in_valid <= '1';
    bit_in <= '0';
    wait until rising_edge(clk);
    bit_in_first <= '0';

    for i in 1 to 31 loop
      bit_in_valid <= '0';
      wait until rising_edge(clk);
      bit_in_valid <= '1';
      wait until rising_edge(clk);
    end loop;
    bit_in_valid <= '0';

    wait;
  end process;

  stream_cipher_inst1 : entity work.stream_cipher
  port map
  (
    clk             => clk,
    reset           => reset,
    --
    data_in         => bit_in,
    data_in_valid   => bit_in_valid,
    data_in_first   => bit_in_first,
    --
    data_out        => encrypted_bit_out,
    data_out_valid  => encrypted_bit_out_valid,
    data_out_first  => encrypted_bit_out_first
  );

  stream_cipher_inst2 : entity work.stream_cipher
  port map
  (
    clk             => clk,
    reset           => reset,
    --
    data_in         => encrypted_bit_out,
    data_in_valid   => encrypted_bit_out_valid,
    data_in_first   => encrypted_bit_out_first,
    --
    data_out        => decrypted_bit_out,
    data_out_valid  => decrypted_bit_out_valid,
    data_out_first  => decrypted_bit_out_first
  );


end architecture;