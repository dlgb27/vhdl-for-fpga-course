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
    leds      : out std_logic_vector(15 downto 0);
    -- 4 GPIO pins, on top row of PMOD JA. JA(0) is pin 1
    JA        : in  std_logic_vector(3 downto 0);
    -- 4 GPIO pins, on top row of PMOD JB. JB(0) is pin 1
    JB        : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of toplevel is

  signal button0_db           : std_logic;
  signal button0_db_r         : std_logic;

  signal start_transfer       : std_logic;

  signal data_to_b2b          : std_logic_vector(1 downto 0);
  signal data_to_b2b_valid    : std_logic;
  signal b2b_ready            : std_logic;

  signal data_from_b2b        : std_logic_vector(1 downto 0);
  signal data_from_b2b_valid  : std_logic;

  signal leds_buf             : std_logic_vector(15 downto 0);
  signal leds_buf_valid       : std_logic;

begin

  debounce_i : entity work.debounce
  port map (clk => clk, bit_in => buttons(0), bit_out => button0_db);

  process(clk) is
  begin
    if rising_edge(clk) then
      button0_db_r <= button0_db;

      start_transfer <= '0';
      if ((button0_db = '1') and (button0_db_r = '0') and (b2b_ready = '1')) then
        start_transfer <= '1';
      end if;
    end if;
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
    data_out_first   => data_to_b2b(1)
  );

  b2b_if_inst : entity work.b2b_if
  generic map
  (
    bits                    => data_to_b2b'length
  )
  port map
  (
    clk_in                  => clk,
    --
    data_in                 => data_to_b2b,
    data_valid_in           => data_to_b2b_valid,
    data_out                => data_from_b2b,
    data_out_valid          => data_from_b2b_valid,
    ready_for_new_data_out  => b2b_ready,
    --
    CLK_PIN_OUT             => JB(0),
    DATA_PINS_OUT           => JB(2 downto 1),
    CLK_PIN_IN              => JA(0),
    DATA_PINS_IN            => JA(2 downto 1)
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

  led_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if (leds_buf_valid = '1') then
        leds <= leds_buf;
      end if;
    end if;
  end process;

end architecture;