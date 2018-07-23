library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
  generic
  (
    bits        : natural
  );
  port
  (
    clk         : in  std_logic;
    --
    pulse_out   : out std_logic
  );
end entity;

architecture rlt of counter is

  signal counter_ur    : unsigned(bits-1 downto 0);

begin

  counter_proc : process(clk) is
  begin
    if rising_edge(clk) then
      counter_ur <= counter_ur + 1;
    end if;
  end process;

  pulse_out <= '1' when counter_ur = (counter_ur'range => '1') else '0';

end architecture;