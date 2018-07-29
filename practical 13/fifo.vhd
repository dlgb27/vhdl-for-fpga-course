library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A simple FIFO that uses a Vivado FIFO IP.

entity fifo is
  port
  (
    clk       : in  std_logic;
    reset_in  : in  std_logic;
    --
    d_in      : in  std_logic_vector(15 downto 0);
    write_in  : in  std_logic;
    full_out  : out std_logic;
    --
    q_out     : out std_logic_vector(15 downto 0);
    read_in   : in  std_logic;
    empty_out : out std_logic
  );
end entity;

architecture rlt of fifo is

  COMPONENT fifo_generator_0
    PORT (
      clk : IN STD_LOGIC;
      srst : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC
    );
  END COMPONENT;

  signal write_r, fifo_write  : std_logic;
  signal read_r,  fifo_read   : std_logic;

begin

  -- Edge detect the write and read signals.
  edge_detect_proc : process(clk) is
  begin
    if rising_edge(clk) then
      write_r <= write_in;
      read_r  <= read_in;
    end if;
  end process;

  fifo_write <= write_in and not write_r;
  fifo_read  <= read_in and not read_r;

  fifo_inst : fifo_generator_0
  PORT MAP (
    clk => clk,
    srst => reset_in,
    din => d_in,
    wr_en => fifo_write,
    rd_en => fifo_read,
    dout => q_out,
    full => full_out,
    empty => empty_out
  );

end architecture;