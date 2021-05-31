library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

-- converts a binary value to decimal.
-- Each set of four bits of the output vector will contain the value 0-9

entity binary_to_decimal is
  generic
  (
    num_decimal_digits : integer := 4
  );
  port
  (
    clk           : in  std_logic;
    --
    value_in      : in  std_logic_vector;
    --
    dec_value_out : out std_logic_vector(num_decimal_digits*4-1 downto 0)
  );
end entity;

architecture rtl of binary_to_decimal is

  type state_t is (setup, calc_digits, ones, output);
  signal state_r : state_t;

  signal intermediate_val : unsigned(value_in'range);

  type digit_values_t is array (natural range <>) of unsigned(3 downto 0);
  signal digit_values : digit_values_t(num_decimal_digits-1 downto 0);

  signal digits_done : std_logic_vector(num_decimal_digits-1 downto 0);

begin

  assert 2**value_in'length - 1 <= 10**num_decimal_digits - 1 report "Not enough decimal digits to represent full input range" severity ERROR;

  fsm_proc : process(clk) is
    variable prev_digit_done : std_logic;
    variable curr_digit_done : std_logic;
  begin
    if rising_edge(clk) then
      case state_r is
        when setup =>
          intermediate_val <= unsigned(value_in);
          digit_values     <= (others => (others => '0'));
          digits_done      <= (others => '0');
          state_r          <= calc_digits;
    
        when calc_digits =>
          for i in digits_done'high downto 1 loop
            if i = digits_done'high then
              prev_digit_done := '1';
            else
              prev_digit_done := digits_done(i+1);
            end if;
            curr_digit_done := digits_done(i);

            if prev_digit_done = '1' and curr_digit_done = '0' then
              if intermediate_val >= 10**i then
                intermediate_val <= intermediate_val - 10**i;
                digit_values(i) <= digit_values(i) + 1;
              else
                digits_done(i) <= '1';
              end if;
            end if;
          end loop;

          if digits_done(1) = '1' then
            -- tens done, now save off ones
            state_r <= ones;
          end if;

        when ones =>
          digit_values(0) <= intermediate_val(digit_values(0)'range);
          state_r  <= output;
        
        when output =>
          for i in 0 to num_decimal_digits-1 loop
            dec_value_out(4*(i+1) - 1 downto 4*i) <= std_logic_vector(digit_values(i));
          end loop;

          state_r <= setup;

        when others =>
          state_r <= setup;
          
      end case;
    end if;
  end process;

end architecture;