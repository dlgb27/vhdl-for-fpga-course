library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
  port
  (
    clk       : in std_logic;
    --
    leds_out  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rlt of rom is

  constant rom_addr_bits    : natural := 4;
  constant rom_depth        : natural := 2**rom_addr_bits;

  type rom_t is array (0 to rom_depth-1) of std_logic_vector(leds_out'range);

  function init_rom return rom_t is
    variable retval     : rom_t;
  begin
    retval(0)   := "1110000000000111";
    retval(1)   := "0111000000001110";
    retval(2)   := "0011100000011100";
    retval(3)   := "0001110000111000";
    retval(4)   := "0000111001110000";
    retval(5)   := "0000011111100000";
    retval(6)   := "0000001111000000";
    retval(7)   := "0000000110000000";
    retval(8)   := "0000000110000000";
    retval(9)   := "0000001001000000";
    retval(10)  := "0000010000100000";
    retval(11)  := "0000100000010000";
    retval(12)  := "0001000000001000";
    retval(13)  := "0010000000000100";
    retval(14)  := "0100000000000010";
    retval(15)  := "1000000000000001";
    return retval;
  end;

  signal rom                : rom_t := init_rom;
  signal rom_address_r      : std_logic_vector(rom_addr_bits-1 downto 0);
  signal count_r            : std_logic_vector(rom_addr_bits+10-1 downto 0);

  attribute ram_style : string;
  attribute ram_style of rom : signal is "distributed";

begin

  addr_proc : process(clk) is
  begin
    if rising_edge(clk) then
      count_r <= std_logic_vector(unsigned(count_r) + 1);
    end if;
  end process;

  rom_address_r <= count_r(count_r'high downto count_r'high-rom_addr_bits+1);

  rom_proc : process(clk) is
  begin
    if rising_edge(clk) then
      leds_out <= rom(to_integer(unsigned(rom_address_r)));
    end if;
  end process;

end architecture;