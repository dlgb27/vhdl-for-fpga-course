library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

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
    --
    seg       : out std_logic_vector(6 downto 0);
    an        : out std_logic_vector(3 downto 0);
    --
    vgaRed    : out std_logic_vector(3 downto 0);
    vgaBlue   : out std_logic_vector(3 downto 0);
    vgaGreen  : out std_logic_vector(3 downto 0);
    Hsync     : out std_logic;
    Vsync     : out std_logic
  );
end entity;

architecture rtl of toplevel is

  constant X_RESOLUTION : integer := 640;
  constant Y_RESOLUTION : integer := 480;

  signal hsync_int, vsync_int, video_on_int, p_tick_int : std_logic;
  signal x_int : std_logic_vector(log_ceil(X_RESOLUTION)-1 downto 0);
  signal y_int : std_logic_vector(log_ceil(Y_RESOLUTION)-1 downto 0);

  signal player_score     : std_logic_vector(7 downto 0);
  signal cpu_score        : std_logic_vector(7 downto 0);
  signal player_score_dec : std_logic_vector(7 downto 0);
  signal cpu_score_dec    : std_logic_vector(7 downto 0);
  signal scores           : std_logic_vector(15 downto 0);

begin

  vga_timing_inst : entity work.vga_timing
  generic map
  (
    X_RESOLUTION => X_RESOLUTION,
    Y_RESOLUTION => Y_RESOLUTION
  )
  port map
  (
    clk           => clk,
    reset         => '0',
    --
    hsync_out     => hsync_int,
    vsync_out     => vsync_int,
    video_on_out  => video_on_int,
    p_tick_out    => p_tick_int,
    x_out         => x_int,
    y_out         => y_int
  );

  -- image_gen_inst : entity work.moving_square_image_generator
  -- generic map
  -- (
  --   X_RESOLUTION => X_RESOLUTION,
  --   Y_RESOLUTION => Y_RESOLUTION
  -- )
  -- port map
  -- (
  --   clk           => clk,
  --   reset         => '0',
  --   --
  --   hsync_in      => hsync_int,
  --   vsync_in      => vsync_int,
  --   video_on_in   => video_on_int,
  --   p_tick_in     => p_tick_int,
  --   x_in          => x_int,
  --   y_in          => y_int,
  --   --
  --   hsync_out     => Hsync,
  --   vsync_out     => Vsync,
  --   r_out         => vgaRed,
  --   g_out         => vgaGreen,
  --   b_out         => vgaBlue
  -- );

  image_gen_inst : entity work.pong
  generic map
  (
    X_RESOLUTION => X_RESOLUTION,
    Y_RESOLUTION => Y_RESOLUTION
  )
  port map
  (
    clk              => clk,
    reset            => switches(0),
    --
    hsync_in         => hsync_int,
    vsync_in         => vsync_int,
    video_on_in      => video_on_int,
    p_tick_in        => p_tick_int,
    x_in             => x_int,
    y_in             => y_int,
    --
    up_in            => buttons(1),
    down_in          => buttons(4),
    cpu_ability_in   => switches(15 downto 6),
    ball_speed_in    => switches(3 downto 1),
    --
    player_score_out => player_score,
    cpu_score_out    => cpu_score,
    --
    hsync_out        => Hsync,
    vsync_out        => Vsync,
    r_out            => vgaRed,
    g_out            => vgaGreen,
    b_out            => vgaBlue
  );

  bin_to_dec_player_inst : entity work.binary_to_decimal
  generic map
  (
    num_decimal_digits => 2
  )
  port map
  (
    clk           => clk,
    --
    value_in      => player_score,
    --
    dec_value_out => player_score_dec
  );

  bin_to_dec_cpu_inst : entity work.binary_to_decimal
  generic map
  (
    num_decimal_digits => 2
  )
  port map
  (
    clk           => clk,
    --
    value_in      => cpu_score,
    --
    dec_value_out => cpu_score_dec
  );

  scores <= player_score_dec & cpu_score_dec;

  seven_seg : entity work.seven_segment_driver
  generic map
  (
    clock_speed_hz => 100000000,
    num_digits     => 4
  )
  port map 
  (
    clk       => clk,
    --
    value_in  => scores,
    --
    cathode   => seg,
    anode     => an
  );

end architecture;