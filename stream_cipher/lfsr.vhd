library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr is
  generic
  (
    length : natural;
    taps   : std_logic_vector
  );
  port
  (
    clk       : in  std_logic;
    reset     : in  std_logic;
    --  
    fill      : in  std_logic_vector(length-1 downto 0);
    --
    ce        : in  std_logic;
    bit_out   : out std_logic
  );
end entity;

architecture rtl of lfsr is

  function xor_reduce(input_vector : std_logic_vector) return std_logic is
    variable ret : std_logic := '0';
  begin
    for i in input_vector'range loop
      ret := ret xor input_vector(i);
    end loop;
    return ret;
  end function;

  signal shift_reg : std_logic_vector(length-1 downto 0);

begin

  lfsr_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if ce = '1' then
        shift_reg <= shift_reg(shift_reg'high-1 downto 0) & xor_reduce(taps and shift_reg);
      end if;
      if reset = '1' then
        shift_reg <= fill;
      end if;
    end if;
  end process;

  bit_out <= shift_reg(shift_reg'high);

end architecture;