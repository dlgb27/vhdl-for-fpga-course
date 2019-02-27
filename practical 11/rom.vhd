library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- An inferred ROM containing a arbitrary pattern.

entity rom is
  port
  (
    clk       : in  std_logic;
    --
    leds_out  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of rom is

  constant rom_addr_bits    : natural := 4;
  constant rom_depth        : natural := 2**rom_addr_bits;
  constant slow_down_bits   : natural := 24;

  type rom_t is array (0 to rom_depth-1) of std_logic_vector(leds_out'range);

  function init_rom return rom_t is
    variable retval     : rom_t;
  begin
    retval(0)   := "1001011001010100";
    retval(1)   := "0100100101010010";
    retval(2)   := "0010111000101001";
    retval(3)   := "1100110010010010";
    retval(4)   := "1001000100100101";
    retval(5)   := "0010110101101010";
    retval(6)   := "0101011110010101";
    retval(7)   := "1001011001000110";
    retval(8)   := "1010001101101001";
    retval(9)   := "0111000101110010";
    retval(10)  := "1100010110000010";
    retval(11)  := "1110100101010001";
    retval(12)  := "1000101101001110";
    retval(13)  := "1010011010110010";
    retval(14)  := "1101010110101111";
    retval(15)  := "1000100011100101";
    return retval;
  end;

  signal rom                : rom_t := init_rom;
  signal rom_address_r      : std_logic_vector(rom_addr_bits-1 downto 0);
  signal count_r            : std_logic_vector(rom_addr_bits+slow_down_bits-1 downto 0);

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