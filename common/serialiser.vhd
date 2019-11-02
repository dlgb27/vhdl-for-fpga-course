library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serialiser is
  port
  (
    clk               : in  std_logic;
    --  
    data_in           : in  std_logic_vector(15 downto 0);
    data_valid_in     : in  std_logic;
    --
    data_out          : out std_logic;
    data_valid_out    : out std_logic;
    data_first_out    : out std_logic
  );
end entity;

architecture rtl of serialiser is

  signal counter_ur       : unsigned(3 downto 0);

  signal latch_valid_r    : std_logic := '0';
  signal latch_first_r    : std_logic := '0';
  signal data_in_latch_r  : std_logic_vector(data_in'range);

begin

  parallel_to_serial_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if (latch_valid_r = '1') then
        counter_ur    <= counter_ur - 1;
        latch_first_r <= '0';
        if (counter_ur = (counter_ur'range => '0')) then
          latch_valid_r <= '0';
        end if;
      end if;

      if (data_valid_in = '1') then
        data_in_latch_r <= data_in;
        counter_ur      <= (others => '1');
        latch_valid_r   <= '1';
        latch_first_r   <= '1';
      end if;
    end if;
  end process;

  output_proc : process(clk) is
  begin
    if rising_edge(clk) then
      data_valid_out <= latch_valid_r;
      data_out       <= data_in_latch_r(to_integer(counter_ur));
      data_first_out <= latch_first_r;
    end if;
  end process;

end architecture;