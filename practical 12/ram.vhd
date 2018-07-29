library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A simple inferred ROM.

entity ram is
  generic
  (
    a_bits    : natural;
    d_bits    : natural
  );
  port
  (
    clk       : in  std_logic;
    --
    d_in      : in  std_logic_vector(d_bits-1 downto 0);
    wr_a_in   : in  std_logic_vector(a_bits-1 downto 0);
    wr_en_in  : in  std_logic;
    --
    q_out     : out std_logic_vector(d_bits-1 downto 0);
    rd_a_in   : in  std_logic_vector(a_bits-1 downto 0)
  );
end entity;

architecture rlt of ram is

  type ram_t is array (0 to (2**a_bits)-1) of std_logic_vector(d_bits-1 downto 0);
  signal ram  : ram_t := (others => (others => '0'));

  attribute ram_style : string;
  attribute ram_style of ram : signal is "block";

begin

  ram_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if (wr_en_in = '1') then
        ram(to_integer(unsigned(wr_a_in))) <= d_in;
      end if;

      q_out <= ram(to_integer(unsigned(rd_a_in)));
    end if;
  end process;

end architecture;