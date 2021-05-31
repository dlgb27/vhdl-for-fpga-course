library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stream_cipher is
  port
  (
    clk             : in  std_logic;
    reset           : in  std_logic;
    --
    data_in         : in  std_logic;
    data_in_valid   : in  std_logic;
    data_in_first   : in  std_logic;
    --
    data_out        : out std_logic;
    data_out_valid  : out std_logic;
    data_out_first  : out std_logic
  );
end entity;

architecture rtl of stream_cipher is

  signal keystream_bit    : std_logic;

  signal data_in_valid_r  : std_logic;
  signal data_in_first_r  : std_logic;
  signal data_in_r        : std_logic;

begin

  keystream_inst : entity work.keystream
  port map
  (
    clk       => clk,
    reset     => reset,
    --
    ce_in     => data_in_valid,
    bit_out   => keystream_bit
  );
  
  input_proc : process(clk) is
  begin
    if rising_edge(clk) then
      data_in_valid_r <= data_in_valid;
      data_in_first_r <= data_in_first;
      data_in_r       <= data_in;
    end if;
  end process;

  output_proc : process(clk) is
  begin
    if rising_edge(clk) then
      data_out       <= data_in_r xor keystream_bit;
      data_out_valid <= data_in_valid_r;
      data_out_first <= data_in_first_r;
    end if;
  end process;

end architecture;