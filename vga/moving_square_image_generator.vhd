library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

entity moving_square_image_generator is
  generic
  (
    X_RESOLUTION : integer := 640;
    Y_RESOLUTION : integer := 480
  );
  port
  (
    clk           : in  std_logic;
    reset         : in  std_logic;
    --
    hsync_in      : in  std_logic;
    vsync_in      : in  std_logic;
    x_in          : in  std_logic_vector(log_ceil(X_RESOLUTION)-1 downto 0);
    y_in          : in  std_logic_vector(log_ceil(Y_RESOLUTION)-1  downto 0);
    p_tick_in     : in  std_logic;
    video_on_in   : in  std_logic;
    --
    hsync_out     : out std_logic;
    vsync_out     : out std_logic;
    r_out         : out std_logic_vector(3 downto 0);
    g_out         : out std_logic_vector(3 downto 0);
    b_out         : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of moving_square_image_generator is

  constant DOT_SIZE : integer := 5;

  signal vsync_in_r     : std_logic;

  signal dot_x_position : unsigned(x_in'range);
  signal dot_y_position : unsigned(y_in'range);

  signal x_direction : std_logic;
  signal y_direction : std_logic;

begin

  process(clk) is
  begin
    if rising_edge(clk) then
      vsync_in_r <= vsync_in;

      if vsync_in_r = '0' and vsync_in = '1' then
        -- new frame
        if x_direction = '1' then
          dot_x_position <= dot_x_position + 1;
          if dot_x_position = X_RESOLUTION - DOT_SIZE then
            x_direction <= '0';
          end if;
        else
          dot_x_position <= dot_x_position - 1;
          if dot_x_position = DOT_SIZE then
            x_direction <= '1';
          end if;
        end if;

        if y_direction = '1' then
          dot_y_position <= dot_y_position + 1;
          if dot_y_position = Y_RESOLUTION - DOT_SIZE then
            y_direction <= '0';
          end if;
        else
          dot_y_position <= dot_y_position - 1;
          if dot_y_position = DOT_SIZE then
            y_direction <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

  process(clk) is
    begin
      if rising_edge(clk) then
        hsync_out <= hsync_in;
        vsync_out <= vsync_in;

        r_out <= (others => '0');
        g_out <= (others => '0');
        b_out <= (others => '0');
        if video_on_in = '1' then
          if unsigned(x_in) >= dot_x_position - DOT_SIZE and unsigned(x_in) <= dot_x_position + DOT_SIZE then
            if unsigned(y_in) >= dot_y_position - DOT_SIZE and unsigned(y_in) <= dot_y_position + DOT_SIZE then
              r_out <= (others => '1');
              g_out <= (others => '1');
              b_out <= (others => '1');
            end if;
          end if;
        end if;
      end if;
    end process;

end architecture;

