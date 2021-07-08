library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_tb is
end entity;

architecture rtl of multiplier_tb is

  constant clk_period : time := 10 ns;
  constant bits       : integer := 8;

  signal clk            : std_logic;
  signal clk_enable     : std_logic := '1';
  signal reset          : std_logic;

  signal fail           : std_logic := '0';

  signal a_in, b_in     : std_logic_vector(bits-1 downto 0);
  signal result         : std_logic_vector(2*bits - 1 downto 0);

begin

  clk_process: process is
  begin
    if (clk_enable = '1') then
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
      clk <= '0';
    else
      wait;
    end if;
  end process;

  stimulus_procsss: process is
  begin
    reset <= '1';
    wait for 100 ns;
    wait until rising_edge(clk);
    reset <= '0';

    wait until rising_edge(clk);
    for i in -2**(a_in'length-1) to 2**(a_in'length-1) - 1 loop
      for j in -2**(b_in'length-1) to 2**(b_in'length-1) - 1 loop
        a_in <= std_logic_vector(to_signed(i, a_in'length));
        b_in <= std_logic_vector(to_signed(j, b_in'length));
        wait for 4*clk_period;
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        if to_integer(signed(result)) /= (i*j) then
          fail <= '1';
        end if;
      end loop;
    end loop;

    wait until rising_edge(clk);

    if (fail = '0') then
      report "Test passed!";
    else
      report "Test failed!";
    end if;
    clk_enable <= '0';
    wait;
  end process;

  uut : entity work.multiplier
  generic map
  (
    bits => bits
  )
  port map 
  (
    clk         => clk,
    --
    a_in        => a_in,
    b_in        => b_in,
    --
    result_out  => result
  );

end architecture;