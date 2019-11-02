library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- latency of 1 clk between ce and bit_out

entity keystream is
  port
  (
    clk       : in  std_logic;
    reset     : in  std_logic;
    --
    ce_in     : in  std_logic;
    bit_out   : out std_logic
  );
end entity;

architecture rtl of keystream is

  constant LENGTH1 : positive := 13;
  constant FILL1   : std_logic_vector(LENGTH1-1 downto 0) := "1100111101110";
  constant TAPS1   : std_logic_vector(LENGTH1-1 downto 0) := "1001100001000"; --(4, 9, 10, 13)

  constant LENGTH2 : positive := 8;
  constant FILL2   : std_logic_vector(LENGTH2-1 downto 0) := "10000111";
  constant TAPS2   : std_logic_vector(LENGTH2-1 downto 0) := "11010100"; --(3, 5, 7, 8)

  constant LENGTH3 : positive := 5;
  constant FILL3   : std_logic_vector(LENGTH3-1 downto 0) := "01101";
  constant TAPS3   : std_logic_vector(LENGTH3-1 downto 0) := "11101"; --(1, 3, 4, 5)

  signal x, y, z   : std_logic;

begin

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
    ce      => ce_in,
    bit_out => x
  );

  lfsr2 : entity work.lfsr
  generic map
  (
    length => LENGTH2,
    taps   => TAPS2
  )
  port map
  (
    clk     => clk,
    reset   => reset,
    --
    fill    => FILL2,
    --
    ce      => ce_in,
    bit_out => y
  );

  lfsr3 : entity work.lfsr
  generic map
  (
    length => LENGTH3,
    taps   => TAPS3
  )
  port map
  (
    clk     => clk,
    reset   => reset,
    --
    fill    => FILL3,
    --
    ce      => ce_in,
    bit_out => z
  );

  geffe_proc : process(clk) is
  begin
    if rising_edge(clk) then
      bit_out <= (x and y) xor ((not x) and z);
    end if;
  end process;

end architecture;