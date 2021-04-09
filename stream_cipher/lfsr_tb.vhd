library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr_tb is
end entity;

architecture rtl of lfsr_tb is

  constant clk_period : time := 10 ns;

  constant LENGTH1    : positive := 13;
  constant FILL1      : std_logic_vector(LENGTH1-1 downto 0) := (LENGTH1-1 => '1', others => '0');
  constant TAPS1      : std_logic_vector(LENGTH1-1 downto 0) := "1001100001000"; --(4, 9, 10, 13)

  signal clk          : std_logic;
  signal reset        : std_logic;

  signal ce           : std_logic;
  signal x            : std_logic;

  signal data_pins    : std_logic_vector(1 downto 0);
  signal clk_pins     : std_logic;
begin

  clk_process: process is
  begin
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
  end process;

  stimulus_procsss: process is
  begin
    ce <= '0';
    reset <= '1';
    wait for 100 ns;
    wait until rising_edge(clk);
    reset <= '0';


    wait for 200ns;
    for i in 0 to 32 loop
      wait until rising_edge(clk);
      ce <= '1';
      wait until rising_edge(clk);
      ce <= '0';
    end loop;

    wait;
  end process;

  lfsr1 : entity work.lfsr
  generic map
  (
    length => LENGTH1,
    taps   => TAPS1
  )
  port map
  (
    clk     => clk,
    reset   => reset,
    --
    fill    => FILL1,
    --
    ce      => ce,
    bit_out => x
  );


end architecture;