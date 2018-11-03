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
    -- 7 segment display
    an        : out std_logic_vector(3 downto 0);
    seg       : out std_logic_vector(6 downto 0);
    dp        : out std_logic
  );
end entity;

architecture rlt of toplevel is

  signal fifo_write, fifo_read    : std_logic;
  signal buttons_deb              : std_logic_vector(buttons'range);

  signal timer_digit              : std_logic_vector(3 downto 0);

begin

  debounce_gen : for i in buttons'range generate
    signal deb, deb_r : std_logic;
  begin
    debounce_i : entity work.debounce
    port map
    (
      clk     => clk,
      bit_in  => buttons(i),
      bit_out => deb
    );

    process(clk) is
    begin
      if rising_edge(clk) then
        deb_r           <= deb;
        buttons_deb(i)  <= deb and not deb_r;
      end if;
    end process;
  end generate;

  fifo_i : entity work.combination_lock
  port map 
  (
    clk         => clk,
    --
    clear_in    => buttons_deb(0),
    buttons_in  => buttons_deb(4 downto 1),
    --
    timer_digit => timer_digit,
    --
    leds        => leds
  );

  sev_seg_i : entity work.seven_seg_driver
  port map
  (
    clk         => clk,
    --
    digit       => timer_digit,
    --
    an          => an,
    seg         => seg,
    dp          => dp
  );

end architecture;