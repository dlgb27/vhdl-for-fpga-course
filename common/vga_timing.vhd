library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

entity vga_timing is
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
    hsync_out     : out std_logic;
    vsync_out     : out std_logic;
    video_on_out  : out std_logic;
    p_tick_out    : out std_logic;
    x_out         : out std_logic_vector(log_ceil(X_RESOLUTION)-1 downto 0);
    y_out         : out std_logic_vector(log_ceil(Y_RESOLUTION)-1 downto 0)
  );
end entity;

architecture rtl of vga_timing is

	-- constant declarations for VGA sync parameters
  -- constant H_L_BORDER      : integer :=  48; -- horizontal left border
  constant H_L_BORDER      : integer :=  64; -- horizontal left border
	constant H_R_BORDER      : integer :=  16; -- horizontal right border
	constant H_RETRACE       : integer :=  96; -- horizontal retrace
	constant H_MAX           : integer := X_RESOLUTION + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
	constant START_H_RETRACE : integer := X_RESOLUTION + H_R_BORDER;
	constant END_H_RETRACE   : integer := X_RESOLUTION + H_R_BORDER + H_RETRACE - 1;

	constant V_T_BORDER      : integer :=  33; -- vertical top border
	constant V_B_BORDER      : integer :=  33; -- vertical bottom border
	constant V_RETRACE       : integer :=   2; -- vertical retrace
	constant V_MAX           : integer := Y_RESOLUTION + V_T_BORDER + V_B_BORDER + V_RETRACE - 1;
  constant START_V_RETRACE : integer := Y_RESOLUTION + V_B_BORDER;
	constant END_V_RETRACE   : integer := Y_RESOLUTION + V_B_BORDER + V_RETRACE - 1;
	
	-- mod-4 counter to generate 25 MHz pixel tick
	signal pixel_reg  : unsigned(1 downto 0);
  signal pixel_tick : std_logic;

	-- registers to keep track of current pixel location
  signal h_count_reg : unsigned(log_ceil(H_MAX+1)-1 downto 0);
  signal v_count_reg : unsigned(log_ceil(V_MAX+1)-1 downto 0);

begin

  process(clk) is
  begin
    if rising_edge(clk) then
      pixel_tick <= '0';

      pixel_reg <= pixel_reg + 1;
      if pixel_reg = (pixel_reg'range => '0') then
        pixel_tick <= '1';
      end if;

      if reset = '1' then
        pixel_reg <= (others => '0');
      end if;
    end if;
  end process;

  process(clk) is
  begin
    if rising_edge(clk) then
      if pixel_tick = '1' then
        h_count_reg <= h_count_reg + 1;
        if h_count_reg = H_MAX then
          h_count_reg <= (others => '0');

          v_count_reg <= v_count_reg + 1;
          if v_count_reg = V_MAX then
            v_count_reg <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process;

  process(clk) is
  begin
    if rising_edge(clk) then
      if h_count_reg >= START_H_RETRACE and h_count_reg <= END_H_RETRACE then
        hsync_out <= '1';
      else
        hsync_out <= '0';
      end if;

      if v_count_reg >= START_V_RETRACE and v_count_reg <= END_V_RETRACE then
        vsync_out <= '1';
      else
        vsync_out <= '0';
      end if;

      if h_count_reg < X_RESOLUTION and v_count_reg < Y_RESOLUTION then
        video_on_out <= '1';
      else
        video_on_out <= '0';
      end if;
    end if;
  end process;
 
  x_out      <= std_logic_vector(h_count_reg(x_out'range));
  y_out      <= std_logic_vector(v_count_reg(y_out'range));
  p_tick_out <= pixel_tick;

end architecture;