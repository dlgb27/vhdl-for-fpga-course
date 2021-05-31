library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A simple inferred(ish) FIFO.

entity fifo is
  generic
  (
    a_bits    : natural;
    d_bits    : natural
  );
  port
  (
    clk       : in  std_logic;
    reset_in  : in  std_logic;
    --
    d_in      : in  std_logic_vector(d_bits-1 downto 0);
    write_in  : in  std_logic;
    --
    q_out     : out std_logic_vector(d_bits-1 downto 0);
    read_in   : in  std_logic;
    --
    full_out  : out std_logic;
    empty_out : out std_logic;
    used_out  : out std_logic_vector(a_bits-1 downto 0)
  );
end entity;

architecture rtl of fifo is

  type ram_t is array (0 to (2**a_bits)-1) of std_logic_vector(d_bits-1 downto 0);
  signal ram  : ram_t := (others => (others => '0'));

  signal write_addr : unsigned(a_bits-1 downto 0);
  signal read_addr  : unsigned(a_bits-1 downto 0);

  signal full_int   : std_logic;
  signal empty_int  : std_logic;

  signal allowed_read  : std_logic;
  signal allowed_write : std_logic;

  signal used_int : unsigned(a_bits-1 downto 0);

  attribute ram_style : string;
  attribute ram_style of ram : signal is "block";

begin

  empty_int <= '1' when write_addr = read_addr else '0';
  full_int  <= '1' when write_addr = (read_addr - 1) else '0';

  allowed_read  <= read_in when (empty_int = '0') else '0';
  allowed_write <= write_in when (full_int = '0') else '0';

  write_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if allowed_write = '1' then
        write_addr <= write_addr + 1;
      end if;
      if reset_in = '1' then
        write_addr <= (others => '0');
      end if;
    end if;
  end process;

  read_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if allowed_read = '1' then
        read_addr <= read_addr + 1;
      end if;
      if reset_in = '1' then
        read_addr <= (others => '0');
      end if;
    end if;
  end process;

  used_proc : process(clk) is
  begin
    if rising_edge(clk) then
      used_int <= write_addr - read_addr;
    end if;
  end process;

  ram_write_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if allowed_write = '1' then
        ram(to_integer(unsigned(write_addr))) <= d_in;
      end if;
    end if;
  end process;

  ram_read_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if allowed_read = '1' then
        q_out <= ram(to_integer(unsigned(read_addr)));
      end if;
      if reset_in = '1' then
        q_out <= (others => '0');
      end if;
    end if;
  end process;

  full_out  <= full_int;
  empty_out <= empty_int;
  used_out  <= std_logic_vector(used_int);

end architecture;