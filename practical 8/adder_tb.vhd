library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_tb is
end entity;

architecture rtl of adder_tb is

  constant clk_period   : time := 10 ns;
  constant bits         : natural := 8;


  signal clk            : std_logic;

  signal a, b           : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal result         : std_logic_vector(bits downto 0);

begin

  clk_process: process is
  begin
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
  end process;

  process(clk) is
  begin
    if rising_edge(clk) then
      a <= std_logic_vector(unsigned(a) + 1);

      if (a = (a'range => '1')) then
        b <= std_logic_vector(unsigned(b) + 1);
      end if;
    end if;
  end process;

  adder_inst : entity work.adder
  generic map
  (
    bits        => 8
  )
  port map 
  (
    clk         => clk,
    --
    a_in        => a,
    b_in        => b,
    --
    result_out  => result
  );

end architecture;