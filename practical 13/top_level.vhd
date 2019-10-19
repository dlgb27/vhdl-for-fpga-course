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
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of toplevel is

  signal fifo_write, fifo_read    : std_logic;
  signal btn2_dbn, btn2_dbn_r     : std_logic;
  signal btn3_dbn, btn3_dbn_r     : std_logic;

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
  port map 
  (
    clk         => clk,
    reset_in    => buttons(0),
    --
    d_in(13 downto 0) => switches(13 downto 0),
    d_in(15 downto 14) => "00",
    write_in    => fifo_write,
    full_out    => leds(14),
    --
    q_out(13 downto 0)  => leds(13 downto 0),
    q_out(15 downto 14) => open,
    read_in     => fifo_read,
    empty_out   => leds(15)
  );

end architecture;