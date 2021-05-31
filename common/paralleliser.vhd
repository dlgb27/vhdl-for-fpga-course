library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity paralleliser is
  port
  (
    clk             : in  std_logic;
    --  
    data_in         : in  std_logic;
    data_valid_in   : in  std_logic;
    data_frame_in   : in  std_logic;
    --
    data_out        : out std_logic_vector(15 downto 0);
    data_valid_out  : out std_logic
  );
end entity;

architecture rtl of paralleliser is

  signal counter_ur         : unsigned(3 downto 0);
  signal data_buf_r         : std_logic_vector(data_out'range);
  signal data_buf_valid_r   : std_logic;

begin

  serial_to_parallel_proc : process(clk) is
  begin
    if rising_edge(clk) then
      data_buf_valid_r <= '0';

      if (data_valid_in = '1') then
        counter_ur <= counter_ur - 1;
        data_buf_r(to_integer(counter_ur)) <= data_in;

        if (counter_ur = (counter_ur'range => '0')) then
          data_buf_valid_r  <= '1';
        end if;

        if (data_frame_in = '1') then
          counter_ur        <= to_unsigned(14, counter_ur'length);
          data_buf_r(15)    <= data_in;
          data_buf_valid_r  <= '0';
        end if;
      end if;
    end if;
  end process;

  output_proc : process(clk) is
  begin
    if rising_edge(clk) then
      data_valid_out <= data_buf_valid_r;
      data_out       <= data_buf_r;
    end if;
  end process;

end architecture;