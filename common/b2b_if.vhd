library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity b2b_if is
  generic
  (
    bits                    : natural
  );
  port
  (
    clk_in                  : in  std_logic;
    reset_in                : in  std_logic;
    --
    data_in                 : in  std_logic_vector(bits-1 downto 0);
    data_valid_in           : in  std_logic;
    data_out                : out std_logic_vector(bits-1 downto 0);
    data_out_valid          : out std_logic;
    ready_for_new_data_out  : out std_logic;
    --
    CLK_PIN_OUT             : out std_logic;
    DATA_PINS_OUT           : out std_logic_vector(bits-1 downto 0);
    CLK_PIN_IN              : in  std_logic;
    DATA_PINS_IN            : in  std_logic_vector(bits-1 downto 0)
  );
end entity;

architecture rtl of b2b_if is

  signal fifo_in     : std_logic_vector(7 downto 0);
  signal fifo_write  : std_logic;
  signal fifo_read   : std_logic;
  signal fifo_empty  : std_logic;
  signal fifo_out    : std_logic_vector(7 downto 0);
  signal fifo_used   : std_logic_vector(10 downto 0);

  type state_t is (idle, hold_data, hold_clock);
  signal state_r : state_t;

  signal counter_ur                       : unsigned(7 downto 0);

  signal clk_pin_in_r, clk_pin_in_rr      : std_logic;
  signal clk_pin_in_rrr                   : std_logic;
  signal data_pins_in_r, data_pins_in_rr  : std_logic_vector(bits-1 downto 0);

  attribute SHREG_EXTRACT : string;
  attribute SHREG_EXTRACT of clk_pin_in_r     : signal is "no";
  attribute SHREG_EXTRACT of clk_pin_in_rr    : signal is "no";
  attribute SHREG_EXTRACT of data_pins_in_r   : signal is "no";
  attribute SHREG_EXTRACT of data_pins_in_rr  : signal is "no";

  COMPONENT b2b_if_fifo
  PORT (
    clk        : IN STD_LOGIC;
    srst       : IN STD_LOGIC;
    din        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en      : IN STD_LOGIC;
    rd_en      : IN STD_LOGIC;
    dout       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full       : OUT STD_LOGIC;
    empty      : OUT STD_LOGIC;
    data_count : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
  );
END COMPONENT;

begin

  assert bits <= 8 report "bits must be less than or equal to 8" severity FAILURE;

  process(fifo_used, data_in, data_valid_in) is
  begin
    -- Signal ready if the fifo is less than half full
    ready_for_new_data_out   <= not fifo_used(fifo_used'high);

    fifo_in                  <= (others => '0');
    fifo_in(bits-1 downto 0) <= data_in;
    fifo_write               <= data_valid_in;
  end process;

  fifo_inst : b2b_if_fifo
  PORT MAP (
    clk        => clk_in,
    srst       => reset_in,
    din        => fifo_in,
    wr_en      => fifo_write,
    rd_en      => fifo_read,
    dout       => fifo_out,
    full       => open,
    empty      => fifo_empty,
    data_count => fifo_used
  );

  -- Tx:
  -- Control the output pins with a state machine.
  -- Rise the clock in the middle of the data.
  -- When new data is available, put the data on the data out pins and wait half a clock cycle.
  -- Then assert the clock and wait the other half.
  -- Then drop the clock and wait for more data to send.
  fsm_proc : process(clk_in) is
  begin
    if rising_edge(clk_in) then
      fifo_read <= '0';

      counter_ur <= counter_ur - 1;

      case state_r is
        when idle =>
          CLK_PIN_OUT <= '0';
          counter_ur  <= (others => '1');

          if (fifo_empty = '0') then
            DATA_PINS_OUT <= fifo_out(DATA_PINS_OUT'range);
            fifo_read     <= '1';
            state_r       <= hold_data;
          end if;

        when hold_data =>
          if (counter_ur = (counter_ur'range => '0')) then
            CLK_PIN_OUT <= '1';
            state_r     <= hold_clock;
            counter_ur  <= (others => '1');
          end if;

        when hold_clock =>
          if (counter_ur = (counter_ur'range => '0')) then
            state_r     <= idle;
          end if;
      end case;
    end if;
  end process;

  -- Rx:
  -- Syncronise the input clock and data onto our local clock to avoid metastability.
  syncronise_proc : process(clk_in) is
  begin
    if rising_edge(clk_in) then
      clk_pin_in_r    <= CLK_PIN_IN;
      clk_pin_in_rr   <= clk_pin_in_r;

      data_pins_in_r  <= DATA_PINS_IN;
      data_pins_in_rr <= data_pins_in_r;
    end if;
  end process;

  -- Edge detect the input clock and assert the data out when we see the clock rise.
  input_proc : process(clk_in) is
  begin
    if rising_edge(clk_in) then
      clk_pin_in_rrr  <= clk_pin_in_rr;

      data_out_valid  <= '0'; 
      if ((clk_pin_in_rrr = '0') and (clk_pin_in_rr = '1')) then
        data_out        <= data_pins_in_rr;
        data_out_valid  <= '1';
      end if;
    end if;
  end process;

end architecture;