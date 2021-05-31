library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

entity pong_game_logic is
  generic
  (
    X_RESOLUTION : integer := 640;
    Y_RESOLUTION : integer := 480;
    DOT_SIZE     : integer := 5;
    BAT_WIDTH    : integer := 5;
    BAT_HEIGHT   : integer := 25
  );
  port
  (
    clk              : in  std_logic;
    reset            : in  std_logic;
    --
    redraw_in        : in  std_logic;
    --
    up_in            : in  std_logic;
    down_in          : in  std_logic;
    cpu_ability_in   : in  std_logic_vector(log_ceil(X_RESOLUTION)-1 downto 0);
    ball_speed_in    : in  std_logic_vector(2 downto 0);
    --
    ball_x_pos_out   : out unsigned(log_ceil(X_RESOLUTION)-1 downto 0);
    ball_y_pos_out   : out unsigned(log_ceil(Y_RESOLUTION)-1 downto 0);
    player_pos_out   : out unsigned(log_ceil(Y_RESOLUTION)-1 downto 0);
    cpu_pos_out      : out unsigned(log_ceil(Y_RESOLUTION)-1 downto 0);
    player_score_out : out unsigned(7 downto 0);
    cpu_score_out    : out unsigned(7 downto 0)
  );
end entity;

architecture rtl of pong_game_logic is

  signal ball_reset       : std_logic;

  signal ball_x_position  : unsigned(ball_x_pos_out'range);
  signal ball_y_position  : unsigned(ball_y_pos_out'range);
  signal ball_x_direction : std_logic;
  signal ball_y_direction : std_logic;

  signal player_position  : unsigned(ball_y_pos_out'range);
  signal cpu_position     : unsigned(ball_y_pos_out'range);

  signal player_scored    : std_logic;
  signal cpu_scored       : std_logic;

  signal player_score     : unsigned(7 downto 0);
  signal cpu_score        : unsigned(7 downto 0);

begin

  ball_position_proc : process(clk) is
  begin
    if rising_edge(clk) then
      ball_reset    <= '0';
      player_scored <= '0';
      cpu_scored    <= '0';

      if redraw_in = '1' then
        -- new frame
        if ball_x_direction = '1' then
          ball_x_position <= ball_x_position + unsigned(ball_speed_in);
          if ball_x_position >= X_RESOLUTION - DOT_SIZE - BAT_WIDTH then
            -- ball hit the right hand side of the screen, check if the cpu bat was there
            if cpu_position + BAT_HEIGHT >= ball_y_position and cpu_position - BAT_HEIGHT <= ball_y_position then
              ball_x_direction <= '0';
            else
              -- cpu lost
              ball_reset    <= '1';
              player_scored <= '1';
            end if;
          end if;
        else
          ball_x_position <= ball_x_position - unsigned(ball_speed_in);
          if ball_x_position <= DOT_SIZE + BAT_WIDTH then
            -- ball hit the left hand side of the screen, check if the player bat was there
            if player_position + BAT_HEIGHT >= ball_y_position and player_position - BAT_HEIGHT <= ball_y_position then
              ball_x_direction <= '1';
            else
              -- player lost
              ball_reset <= '1';
              cpu_scored <= '1';
            end if;
          end if;
        end if;

        if ball_y_direction = '1' then
          ball_y_position <= ball_y_position + unsigned(ball_speed_in);
          if ball_y_position >= Y_RESOLUTION - DOT_SIZE then
            ball_y_direction <= '0';
          end if;
        else
          ball_y_position <= ball_y_position - unsigned(ball_speed_in);
          if ball_y_position <= DOT_SIZE then
            ball_y_direction <= '1';
          end if;
        end if;
      end if;

      if ball_reset = '1' or reset = '1' then
        ball_x_position  <= to_unsigned(X_RESOLUTION/2, ball_x_position'length);
        ball_y_position  <= to_unsigned(Y_RESOLUTION/2, ball_y_position'length);
        ball_x_direction <= '1';
        ball_y_direction <= '1';
      end if;
    end if;
  end process;

  player_position_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if redraw_in = '1' then
        if up_in = '1' then
          player_position <= player_position - 1;
        end if;
        if down_in = '1' then
          player_position <= player_position + 1;
        end if;
      end if;

      if reset = '1' then
        player_position <= to_unsigned(Y_RESOLUTION/2, player_position'length);
      end if;
    end if;
  end process;

  cpu_position_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if redraw_in = '1' then
        if ball_x_position > X_RESOLUTION - unsigned(cpu_ability_in) then
          if ball_y_position > cpu_position then
            cpu_position <= cpu_position + 1;
          else
            cpu_position <= cpu_position - 1;
          end if;
        end if;
      end if;

      if reset = '1' then
        cpu_position <= to_unsigned(Y_RESOLUTION/2, cpu_position'length);
      end if;
    end if;
  end process;

  score_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if cpu_scored = '1' then
        cpu_score <= cpu_score + 1;
      end if;

      if player_scored = '1' then
        player_score <= player_score + 1;
      end if;

      if reset = '1' then
        player_score <= (others => '0');
        cpu_score    <= (others => '0');
      end if;
    end if;
  end process;

  process(clk) is
    begin
      if rising_edge(clk) then
        ball_x_pos_out   <= ball_x_position;
        ball_y_pos_out   <= ball_y_position;
        player_pos_out   <= player_position;
        cpu_pos_out      <= cpu_position;
        player_score_out <= player_score;
        cpu_score_out    <= cpu_score;
      end if;
    end process;

end architecture;

