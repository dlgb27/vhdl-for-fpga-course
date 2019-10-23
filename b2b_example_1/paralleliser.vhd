library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity paralleliser is
  port
  (
    clk            : in  std_logic;
    --  
    data_in        : in  std_logic;
    data_in_valid  : in  std_logic;
    data_in_frame  : in  std_logic;
    --
    data_out         : out std_logic_vector(15 downto 0);
    data_out_valid   : out std_logic
  );
end entity;

architecture rtl of paralleliser is

  signal counter_ur     : unsigned(3 downto 0);
  signal data_buf       : std_logic_vector(data_out'range);
  signal data_buf_valid : std_logic;

begin

  process(clk) is
  begin
    if rising_edge(clk) then
      data_buf_valid <= '0';

      if data_in_valid = '1' then
        counter_ur <= counter_ur - 1;
        data_buf(to_integer(counter_ur)) <= data_in;

        if counter_ur = (counter_ur'range => '0') then
          data_buf_valid <= '1';
        end if;

        if data_in_frame = '1' then
          counter_ur     <= to_unsigned(14, counter_ur'length);
          data_buf(15)   <= data_in;
          data_buf_valid <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk) is
  begin
    if rising_edge(clk) then
      data_out_valid <= data_buf_valid;
      data_out       <= data_buf;
    end if;
  end process;

end architecture;