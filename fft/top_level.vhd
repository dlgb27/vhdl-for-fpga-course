library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
  port
  (
    clk       : in  std_logic;
    --  
    switches  : in  std_logic_vector(15 downto 0);
    --
    buttons   : in  std_logic_vector(4 downto 0);
    --
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of toplevel is

  constant THRESHOLD_STEP_SIZE : positive := 256;
  constant THRESHOLD_DEFAULT   : positive := 1024;

  signal reset                 : std_logic;

  signal button_up_db          : std_logic;
  signal button_down_db        : std_logic;
  signal button_up_db_r        : std_logic;
  signal button_down_db_r      : std_logic;

  -- Initialising this to avoid having to press reset initially
  signal fft_threshold_ur      : unsigned(14 downto 0) := to_unsigned(THRESHOLD_DEFAULT, 15);

begin

  reset <= buttons(0);

  -- debounce button 1 (up) and button 4 (down)
  db_1 : entity work.debounce
  port map
  (
    clk     => clk,
    --
    bit_in  => buttons(1),
    --
    bit_out => button_up_db
  );

  db_4 : entity work.debounce
  port map
  (
    clk     => clk,
    --
    bit_in  => buttons(4),
    --
    bit_out => button_down_db
  );

  -- Move the threshold for LEDs to be on/off up and down with the up/down buttons
  fft_peak_threshold_proc : process(clk) is
  begin
    if rising_edge(clk) then
      button_up_db_r   <= button_up_db;
      button_down_db_r <= button_down_db;

      if ((button_up_db = '1') and (button_up_db_r = '0')) then
        fft_threshold_ur <= fft_threshold_ur + THRESHOLD_STEP_SIZE;
      elsif ((button_down_db = '1') and (button_down_db_r = '0')) then
        fft_threshold_ur <= fft_threshold_ur - THRESHOLD_STEP_SIZE;
      end if;
      if (reset = '1') then
        fft_threshold_ur <= to_unsigned(THRESHOLD_DEFAULT, fft_threshold_ur'length);
      end if;
    end if;
  end process;

  fft_inst : entity work.fft_1bit
  port map
  (
    clk                 => clk,
    --
    real_samples_in     => switches,
    --
    power_threshold_in  => std_logic_vector(fft_threshold_ur),
    --
    peaks_out           => leds
  );

end architecture;