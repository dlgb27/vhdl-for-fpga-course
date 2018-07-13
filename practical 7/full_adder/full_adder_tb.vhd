library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity example_tb is
end entity;

architecture rlt of example_tb is

  constant clk_period : time := 10 ns;

  signal clk            : std_logic;
  signal reset          : std_logic;

  signal a, b, c        : std_logic;
  signal result, carry  : std_logic;

begin

  clk_process: process is
  begin
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
  end process;

  stimulus_procsss: process is
    variable fail : std_logic := '0';
  begin
    reset <= '1';
    wait for 100 ns;
    wait until rising_edge(clk);
    reset <= '0';

    wait until rising_edge(clk);
    a <= '0';
    b <= '0';
    wait until rising_edge(clk);
    if ((result /= '0') or (carry /= '0')) then
      fail := '1';
    end if;
    a <= '1';
    b <= '0';
    wait until rising_edge(clk);
    if ((result /= '1') or (carry /= '0')) then
      fail := '1';
    end if;
    a <= '0';
    b <= '1';
    wait until rising_edge(clk);
    if ((result /= '1') or (carry /= '0')) then
      fail := '1';
    end if;
    a <= '1';
    b <= '1';
    wait until rising_edge(clk);
    if ((result /= '1') or (carry /= '1')) then
      fail := '1';
    end if;
    if (fail = '0') then
      report "Test passed!";
    else
      report "Test failed!";
    end if;
    wait;
  end process;

  uut : entity work.full_adder
  port map 
  (
    a_in        => a,
    b_in        => b,
    carry_in    => c,
    --
    result_out  => result,
    carry_out   => carry
  );

end architecture;