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
    locked_out  : out std_logic
  );
end entity;

architecture rlt of combination_lock is

  type state_t is (locked, code1, code2, code3, unlocked);
  signal state_r : state_t;

begin

  fsm_proc : process(clk) is
  begin
    if rising_edge(clk) then
      case state_r is
        when locked =>
          locked_out <= '1';
          --
          if (buttons_in(2) = '1') then
            state_r   <= code1;
          end if;
        when code1 =>
          locked_out <= '1';
          --
          if (buttons_in(1) = '1') then
            state_r   <= code2;
          end if;
          --
          if (clear_in = '1') then
            state_r   <= locked;
          end if;
        when code2 =>
          locked_out <= '1';
          --
          if (buttons_in(2) = '1') then
            state_r   <= code3;
          end if;
          --
          if (clear_in = '1') then
            state_r   <= locked;
          end if;
        when code3 =>
          locked_out <= '1';
          --
          if (buttons_in(0) = '1') then
            state_r   <= unlocked;
          end if;
          --
          if (clear_in = '1') then
            state_r   <= locked;
          end if;
        when unlocked =>
          locked_out <= '0';
          --
          if (clear_in = '1') then
            state_r   <= locked;
          end if;
      end case;
    end if;
  end process;

end architecture;