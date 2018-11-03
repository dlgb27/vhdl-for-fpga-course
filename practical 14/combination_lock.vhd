library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A combination lock written using an FSM.

entity combination_lock is
  port
  (
    clk         : in  std_logic;
    --
    clear_in    : in  std_logic;
    buttons_in  : in  std_logic_vector(3 downto 0);
    --
    timer_digit : out std_logic_vector(3 downto 0);
    --
    leds        : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rlt of combination_lock is
  constant ONE_SEC      : unsigned(26 downto 0) := to_unsigned(100000000, 27);

  type state_t is (locked, code1, code2, code3, unlocked, code_error);
  signal state_r, state_rr : state_t;

  signal timer_u        : unsigned(28 downto 0);
  signal timer_ur       : unsigned(27 downto 0);

  signal timer_pulse_r  : std_logic;

  signal code_timer_ur  : unsigned(26 downto 0) := ONE_SEC;
  signal code_digit     : unsigned(3 downto 0);
  signal code_timer_expired : std_logic;

begin

  fsm_proc : process(clk) is
  begin
    if rising_edge(clk) then
      leds <= (others => '0');

      case state_r is
        when locked =>
          leds(0) <= '1';
          --
          if (buttons_in(2) = '1') then
            state_r   <= code1;
          elsif (buttons_in /= (buttons_in'range => '0')) then
            state_r   <= code_error;
          end if;
        when code1 =>
          leds(0) <= '1';
          --
          if (buttons_in(1) = '1') then
            state_r   <= code2;
          elsif (buttons_in /= (buttons_in'range => '0')) then
            state_r   <= code_error;
          end if;
          --
          if (code_timer_expired = '1') then
            state_r <= code_error;
          end if;
          --
          if (clear_in = '1') then
            state_r   <= locked;
          end if;
        when code2 =>
          leds(0) <= '1';
          --
          if (buttons_in(2) = '1') then
            state_r   <= code3;
          elsif (buttons_in /= (buttons_in'range => '0')) then
            state_r   <= code_error;
          end if;
          --
          if (code_timer_expired = '1') then
            state_r <= code_error;
          end if;
          --
          if (clear_in = '1') then
            state_r   <= locked;
          end if;
        when code3 =>
          leds(0) <= '1';
          --
          if (buttons_in(0) = '1') then
            state_r   <= unlocked;
          elsif (buttons_in /= (buttons_in'range => '0')) then
            state_r   <= code_error;
          end if;
          --
          if (code_timer_expired = '1') then
            state_r <= code_error;
          end if;
          --
          if (clear_in = '1') then
            state_r   <= locked;
          end if;
        when unlocked =>
          leds(0) <= '0';
          --
          if (clear_in = '1') then
            state_r   <= locked;
          end if;
        when code_error =>
          leds <= (others => '1');

          if (timer_pulse_r = '1') then
            state_r <= locked;
          end if;
      end case;
    end if;
  end process;

  timer_u <= ('0' & timer_ur) + 1;

  timer_proc : process(clk) is
  begin
    if rising_edge(clk) then
      timer_ur      <= timer_u(timer_ur'range);
      timer_pulse_r <= timer_u(timer_u'high);

      state_rr <= state_r;

      if (state_r /= state_rr) then
        timer_ur      <= (others => '0');
        timer_pulse_r <= '0';
      end if;
    end if;
  end process;

  code_timer_proc : process(clk) is
  begin
    if rising_edge(clk) then
      code_timer_expired <= '0';

      if (state_r = locked) then
        code_timer_ur <= ONE_SEC;
        code_digit    <= X"9";
      elsif (state_r /= unlocked) then
        code_timer_ur <= code_timer_ur - 1;
      end if;

      if (code_timer_ur = (code_timer_ur'range => '0')) then
        code_timer_ur <= ONE_SEC;
        if (code_digit /= (code_digit'range => '0')) then
          code_digit    <= code_digit - 1;
        else
          code_timer_expired <= '1';
        end if;
      end if;
    end if;
  end process;

  timer_digit <= std_logic_vector(code_digit);

end architecture;