library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.al;

entity b2b is
  generic
  (
    bits                    : natural
  );
  port
  (
    clk_in		              : in  std_logic
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

architecture rtl of b2b is

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

begin

  -- Tx:
  -- Control the output pins with a state machine.
  -- Rise the clock in the middle of the data.
  -- When new data is available, put the data on the data out pins and wait half a clock cycle.
  -- Then assert the clock and wait the other half.
  -- Then drop the clock and wait for more data to send.
  fsm_proc : process(clk) is
  begin
    if rising_edge(clk) then

      counter_ur <= counter_ur - 1;
      
      case state_r is
        when idle =>
          ready_for_new_data_out  <= '1';
          CLK_PIN_OUT             <= '0';
          counter_ur              <= (others => '1');

          if (data_valid_in = '1') then
            DATA_PINS_OUT <= data_in;
            state         <= hold_data;
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
  syncronise_proc : process(clk) is
  begin
    if rising_edge(clk) then
      clk_pin_in_r    <= CLK_PIN_IN;
      clk_pin_in_rr   <= clk_pin_in_r;

      data_pins_in_r  <= DATA_PINS_IN;
      data_pins_in_rr <= data_pins_in_r
    end if;
  end process;

  -- Edge detect the input clock and assert the data out when we see the clock rise.
  input_proc : process(clk) is
  begin
    if rising_edge(clk) then
      clk_pin_in_rrr  <= clk_pin_in_rr;

      data_out_valid  <= '0'; 
      if ((clk_pin_in_rrr = '1') and (clk_pin_in_rr = '0')) then
        data_out        <= data_pins_in_rr;
        data_out_valid  <= '1';
      end if;
    end if;
  end process;

end architecture;