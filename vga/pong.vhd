library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

entity pong is
  generic
  (
    X_RESOLUTION : integer := 640;
    Y_RESOLUTION : integer := 480
  );
  port
  (
    clk              : in  std_logic;
    reset            : in  std_logic;
    --
    hsync_in         : in  std_logic;
    vsync_in         : in  std_logic;
    x_in             : in  std_logic_vector(log_ceil(X_RESOLUTION)-1 downto 0);
    y_in             : in  std_logic_vector(log_ceil(Y_RESOLUTION)-1 downto 0);
    p_tick_in        : in  std_logic;
    video_on_in      : in  std_logic;
    --
    up_in            : in  std_logic;
    down_in          : in  std_logic;
    ball_speed_in    : in  std_logic_vector(2 downto 0);
    cpu_ability_in   : in  std_logic_vector(log_ceil(X_RESOLUTION)-1 downto 0);
    --
    player_score_out : out std_logic_vector(7 downto 0);
    cpu_score_out    : out std_logic_vector(7 downto 0);
    --
    hsync_out        : out std_logic;
    vsync_out        : out std_logic;
    r_out            : out std_logic_vector(3 downto 0);
    g_out            : out std_logic_vector(3 downto 0);
    b_out            : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of pong is

  constant DOT_SIZE       : integer := 5;
  constant BAT_WIDTH      : integer := 5;
  constant BAT_HEIGHT     : integer := 25;

  signal ball_x_position  : unsigned(x_in'range);
  signal ball_y_position  : unsigned(y_in'range);

  signal player_position  : unsigned(y_in'range);
  signal cpu_position     : unsigned(y_in'range);

  signal redraw           : std_logic;
  signal hsync_in_r       : std_logic;
  signal vsync_in_r       : std_logic;
  signal video_on_in_r    : std_logic;

  signal draw_ball        : std_logic;
  signal draw_player      : std_logic;
  signal draw_cpu         : std_logic;

  signal player_score_int : unsigned(7 downto 0);
  signal cpu_score_int    : unsigned(7 downto 0);

begin

  process(clk) is
  begin
    if rising_edge(clk) then
      redraw <= '0';

      if vsync_in = '1' and vsync_in_r = '0' then
        redraw <= '1';
      end if;
    end if;
  end process;

  game_logic_inst : entity work.pong_game_logic
  generic map
  (
    X_RESOLUTION => X_RESOLUTION,
    Y_RESOLUTION => Y_RESOLUTION,
    DOT_SIZE     => DOT_SIZE,
    BAT_WIDTH    => BAT_WIDTH,
    BAT_HEIGHT   => BAT_HEIGHT
  )
  port map
  (
    clk              => clk,
    reset            => reset,
    --
    redraw_in        => redraw,
    --
    up_in            => up_in,
    down_in          => down_in,
    cpu_ability_in   => cpu_ability_in,
    ball_speed_in    => ball_speed_in,
    --
    ball_x_pos_out   => ball_x_position,
    ball_y_pos_out   => ball_y_position,
    player_pos_out   => player_position,
    cpu_pos_out      => cpu_position,
    player_score_out => player_score_int,
    cpu_score_out    => cpu_score_int
  );

  player_score_out <= std_logic_vector(player_score_int);
  cpu_score_out    <= std_logic_vector(cpu_score_int);

  process(clk) is
  begin
    if rising_edge(clk) then
      hsync_in_r    <= hsync_in;
      vsync_in_r    <= vsync_in;
      video_on_in_r <= video_on_in;

      draw_ball   <= '0';
      draw_player <= '0';
      draw_cpu    <= '0';

      if unsigned(x_in) >= ball_x_position - DOT_SIZE and unsigned(x_in) <= ball_x_position + DOT_SIZE then
        if unsigned(y_in) >= ball_y_position - DOT_SIZE and unsigned(y_in) <= ball_y_position + DOT_SIZE then
          draw_ball <= '1';
        end if;
      end if;

      if unsigned(x_in) <= BAT_WIDTH then
        if unsigned(y_in) >= player_position - BAT_HEIGHT and unsigned(y_in) <= player_position + BAT_HEIGHT then
          draw_player <= '1';
        end if;
      end if;

      if unsigned(x_in) >= X_RESOLUTION - BAT_WIDTH then
        if unsigned(y_in) >= cpu_position - BAT_HEIGHT and unsigned(y_in) <= cpu_position + BAT_HEIGHT then
          draw_cpu <= '1';
        end if;
      end if;
    end if;
  end process;

  process(clk) is
    begin
      if rising_edge(clk) then
        hsync_out <= hsync_in_r;
        vsync_out <= vsync_in_r;

        r_out <= (others => '0');
        g_out <= (others => '0');
        b_out <= (others => '0');

        if video_on_in_r = '1' then
          if draw_ball = '1' then
            r_out(r_out'high) <= '1';
            r_out(r_out'high-1 downto 0) <= std_logic_vector(ball_x_position(6+r_out'length-2 downto 6));
            g_out(g_out'high) <= '1';
            g_out(g_out'high-1 downto 0) <= std_logic_vector(ball_y_position(6+r_out'length-2 downto 6));
            b_out(b_out'high) <= '1';
            b_out(b_out'high-1 downto 0) <= std_logic_vector(ball_x_position(7+r_out'length-2 downto 7));
          elsif draw_player = '1' or draw_cpu = '1' then
            r_out <= (others => '1');
            g_out <= (others => '1');
            b_out <= (others => '1');
          end if;
        end if;
      end if;
    end process;

end architecture;

