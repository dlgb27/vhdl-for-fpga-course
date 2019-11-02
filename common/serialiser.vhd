library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serialiser is
  port
  (
    clk            : in  std_logic;
    --  
    data_in        : in  std_logic_vector(15 downto 0);
    data_in_valid  : in  std_logic;
    --
    data_out         : out std_logic;
    data_out_valid   : out std_logic;
    data_out_first   : out std_logic
  );
end entity;

architecture rtl of serialiser is

  signal counter_ur    : unsigned(3 downto 0);

  signal latch_valid   : std_logic := '0';
  signal latch_first   : std_logic := '0';
  signal data_in_latch : std_logic_vector(data_in'range);

begin

  process(clk) is
  begin
    if rising_edge(clk) then
      if latch_valid = '1' then
        counter_ur  <= counter_ur - 1;
        latch_first <= '0';
        if counter_ur = (counter_ur'range => '0') then
          latch_valid <= '0';
        end if;
      end if;

      if data_in_valid = '1' then
        data_in_latch <= data_in;
        counter_ur    <= (others => '1');
        latch_valid   <= '1';
        latch_first   <= '1';
      end if;
    end if;
  end process;

  process(clk) is
  begin
    if rising_edge(clk) then
      data_out_valid <= latch_valid;
      data_out       <= data_in_latch(to_integer(counter_ur));
      data_out_first <= latch_first;
    end if;
  end process;

end architecture;