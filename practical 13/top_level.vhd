library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    an        : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of toplevel is

  signal fifo_write, fifo_read    : std_logic;
  signal btn2_dbn, btn2_dbn_r     : std_logic;
  signal btn3_dbn, btn3_dbn_r     : std_logic;
  signal used : std_logic_vector(3 downto 0);
  signal used_extended : std_logic_vector(15 downto 0);

begin

  write_debounce_i : entity work.debounce
  port map (clk => clk, bit_in => buttons(2), bit_out => btn2_dbn);

  read_debounce_i : entity work.debounce
  port map (clk => clk, bit_in => buttons(3), bit_out => btn3_dbn);

  button_edge_proc : process(clk) is
  begin
    if rising_edge(clk) then
      btn2_dbn_r <= btn2_dbn;
      btn3_dbn_r <= btn3_dbn; 
    end if;
  end process;
  
  fifo_write <= btn2_dbn and not btn2_dbn_r;
  fifo_read  <= btn3_dbn and not btn3_dbn_r;
  

  fifo_i : entity work.fifo
  generic map
  (
    a_bits      => 4,
    d_bits      => 14
  )
  port map
  (
    clk         => clk,
    reset_in    => buttons(0),
    --
    d_in        => switches(13 downto 0),
    write_in    => fifo_write,
    full_out    => leds(14),
    --
    q_out       => leds(13 downto 0),
    read_in     => fifo_read,
    empty_out   => leds(15),
    used_out    => used
  );

  used_extended <= x"000" & used;

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
    value_in  => used_extended,
    --
    cathode   => seg,
    anode     => an
  );

end architecture;