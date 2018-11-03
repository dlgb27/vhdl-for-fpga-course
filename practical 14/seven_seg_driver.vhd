library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_seg_driver is
  port
  (
    clk       : in  std_logic;
    --
    digit     : in  std_logic_vector(3 downto 0);
    -- 7 segment display
    an        : out std_logic_vector(3 downto 0);
    seg       : out std_logic_vector(6 downto 0);
    dp        : out std_logic
  );
end entity;

architecture rlt of seven_seg_driver is

  signal mux_digit  : std_logic_vector(3 downto 0);

begin

  an  <= "1110";
  dp  <= '1';

  mux_digit <= digit;

  seg_drive_proc : process(clk) is
  begin
    if rising_edge(clk) then
      case (mux_digit) is
        when "0000" => -- 0
          seg   <= "1000000";
        when "0001" => -- 1
          seg   <= "1111001";
        when "0010" => -- 2
          seg   <= "0100100";
        when "0011" => -- 3
          seg   <= "0110000";
        when "0100" => -- 4
          seg   <= "0011001";
        when "0101" => -- 5
          seg   <= "0010010";
        when "0110" => -- 6
          seg   <= "0000010";
        when "0111" => -- 7
          seg   <= "1111000";
        when "1000" => -- 8
          seg   <= "0000000";
        when "1001" => -- 9
          seg   <= "0010000";
        when others =>
          seg   <= (others => '0');
      end case;
    end if;
  end process;

end architecture;