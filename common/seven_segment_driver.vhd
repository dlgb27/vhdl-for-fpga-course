library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

entity seven_segment_driver is
  generic
  (
    clock_speed_hz : integer := 100000000;
    num_digits     : integer := 4
  );
  port
  (
    clk       : in  std_logic;
    --
    value_in  : in  std_logic_vector(num_digits*4-1 downto 0);
    --
    cathode   : out std_logic_vector(6 downto 0);
    anode     : out std_logic_vector(num_digits-1 downto 0)
  );
end entity;

architecture rtl of seven_segment_driver is

  constant REFRESH_RATE_S : real := 0.01; -- 10ms
  constant COUNTER_LIMIT  : integer := integer(real(clock_speed_hz) * REFRESH_RATE_S / real(num_digits));

  function get_cathode_from_digit(digit : std_logic_vector(3 downto 0)) return std_logic_vector is
    variable ret : std_logic_vector(6 downto 0) := "1000000";
  begin
    case to_integer(unsigned(digit)) is
      when 0  => ret := "1000000";
      when 1  => ret := "1111001";
      when 2  => ret := "0100100";
      when 3  => ret := "0110000";
      when 4  => ret := "0011001";
      when 5  => ret := "0010010";
      when 6  => ret := "0000010";
      when 7  => ret := "1111000";
      when 8  => ret := "0000000";
      when 9  => ret := "0010000";
      when 10 => ret := "0100000";
      when 11 => ret := "0000011";
      when 12 => ret := "1000110";
      when 13 => ret := "0100001";
      when 14 => ret := "0000110";
      when 15 => ret := "0001110";
    end case;
    return ret;
  end function;

  signal refresh_counter : unsigned(log_ceil(COUNTER_LIMIT)-1 downto 0);
  signal switch_anode    : std_logic;
  signal anode_select    : std_logic_vector(anode'range) := "0111"; -- one-hot anode select (active low)

begin

  refresh_rate_process : process(clk) is
  begin
    if rising_edge(clk) then
      switch_anode <= '0';

      refresh_counter <= refresh_counter + 1;
      if refresh_counter = COUNTER_LIMIT-1 then
        refresh_counter <= (others => '0');
        switch_anode    <= '1';
      end if;
    end if;
  end process;

  anode_select_process : process(clk) is
  begin
    if rising_edge(clk) then
      if switch_anode = '1' then
        anode_select <= anode_select(anode_select'high-1 downto 0) & anode_select(anode_select'high);
      end if;
    end if;
  end process;

  input_select_process : process(clk) is
    variable digit : std_logic_vector(3 downto 0);
  begin
    if rising_edge(clk) then
      for i in 0 to num_digits-1 loop
        if anode_select(i) = '0' then
          digit := value_in((i+1)*4 - 1 downto i*4);
          cathode <= get_cathode_from_digit(digit);
        end if;
      end loop;
    end if;
  end process;

  output_anode : process(clk) is
  begin
    if rising_edge(clk) then
      anode <= anode_select;
    end if;
  end process;

end architecture;