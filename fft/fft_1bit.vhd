library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Continuously performs an FFT of the 16 1-bit samples present in real_samples_in.
-- Each bit of real_samples_in corresponds to the sign of each of the 16 real input
-- samples to the FFT.
-- Each bit in peaks_out is '1' if the power in that frequency bin is higher than
-- power_threshold_in.
-- The DC bin is peaks_out(8). Bin "fs/2" is peaks_out(0) and "-fs/2 + fs/16" is
-- peaks_out(15).

entity fft_1bit is
  port
  (
    clk                 : in  std_logic;
    --
    real_samples_in     : in  std_logic_vector(15 downto 0);
    --
    power_threshold_in  : in  std_logic_vector(14 downto 0);
    --
    peaks_out           : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of fft_1bit is

  COMPONENT xfft_0
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_config_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axis_config_tvalid : IN STD_LOGIC;
    s_axis_config_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tlast : IN STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tready : IN STD_LOGIC;
    m_axis_data_tlast : OUT STD_LOGIC;
    event_frame_started : OUT STD_LOGIC;
    event_tlast_unexpected : OUT STD_LOGIC;
    event_tlast_missing : OUT STD_LOGIC;
    event_status_channel_halt : OUT STD_LOGIC;
    event_data_in_channel_halt : OUT STD_LOGIC;
    event_data_out_channel_halt : OUT STD_LOGIC
  );
END COMPONENT;

signal input_counter_ur   : unsigned(3 downto 0) := (others => '0');
signal fft_in_re_r        : std_logic_vector(7 downto 0);
signal fft_in_im_r        : std_logic_vector(7 downto 0);
signal fft_in_last_r      : std_logic;
signal fft_in_ready       : std_logic;

signal fft_out_re         : std_logic_vector(7 downto 0);
signal fft_out_im         : std_logic_vector(7 downto 0);
signal fft_out_valid      : std_logic;
signal fft_out_last       : std_logic;

signal fft_out_re_r       : std_logic_vector(fft_in_re_r'range);
signal fft_out_im_r       : std_logic_vector(fft_in_im_r'range);
signal fft_out_valid_r    : std_logic;
signal fft_out_last_r     : std_logic;

signal fft_out_re_rr      : std_logic_vector(fft_in_re_r'range);
signal fft_out_im_rr      : std_logic_vector(fft_in_im_r'range);
signal fft_out_valid_rr   : std_logic;
signal fft_out_last_rr    : std_logic;

signal fft_re_sq_r        : signed(fft_in_re_r'length*2-1 downto 0);
signal fft_im_sq_r        : signed(fft_in_im_r'length*2-1 downto 0);
signal fft_out_valid_rrr  : std_logic;
signal fft_out_last_rrr   : std_logic;

signal fft_re_sq_rr       : signed(fft_re_sq'high-1 downto 0);
signal fft_im_sq_rr       : signed(fft_im_sq'high-1 downto 0);
signal fft_out_valid_r4   : std_logic;
signal fft_out_last_r4    : std_logic;

signal fft_mag_sq_ur      : unsigned(fft_re_sq_rr'range);
signal fft_mag_sq_valid_r : std_logic;
signal fft_mag_sq_last_r  : std_logic;

signal output_counter_ur  : unsigned(3 downto 0);

signal output_buf_r       : std_logic_vector(15 downto 0);
signal output_buf_valid_r : std_logic;

attribute USE_DSP : string;
attribute USE_DSP of fft_re_sq : signal is "yes";
attribute USE_DSP of fft_im_sq : signal is "yes";

begin

  -- Serially feed the FFT IP core with real samples.
  -- The indexing of the vector allows a waveform to be drawn on the switches from
  -- left to right with the first sample in time on the left most switch.
  fft_input_proc : process(clk) is
  begin
    if rising_edge(clk) then
      fft_in_last_r   <= '0';

      if (fft_in_ready = '1') then
        input_counter_ur <= input_counter_ur - 1;
      end if;

      if (real_samples_in(to_integer(input_counter_ur)) = '1') then
        fft_in_re_r <= std_logic_vector(to_signed(64, fft_in_re_r'length));
      else
        fft_in_re_r <= std_logic_vector(to_signed(-64, fft_in_re_r'length));
      end if;

      if (input_counter_ur = (input_counter_ur'range => '0')) then
        fft_in_last_r <= '1';
      end if;
    end if;
  end process;

  fft_in_im_r <= (others => '0');

  fft_inst : xfft_0
  PORT MAP (
    aclk                           => clk,
    s_axis_config_tdata            => (others => '0'),
    s_axis_config_tvalid           => '0',
    s_axis_config_tready           => open,

    s_axis_data_tdata(7 downto 0)  => fft_in_re_r,
    s_axis_data_tdata(15 downto 8) => fft_in_im_r,
    s_axis_data_tvalid             => '1',
    s_axis_data_tready             => fft_in_ready,
    s_axis_data_tlast              => fft_in_last_r,

    m_axis_data_tdata(7 downto 0)  => fft_out_re,
    m_axis_data_tdata(15 downto 8) => fft_out_im,
    m_axis_data_tvalid             => fft_out_valid,
    m_axis_data_tready             => '1',
    m_axis_data_tlast              => fft_out_last,

    event_frame_started            => open,
    event_tlast_unexpected         => open,
    event_tlast_missing            => open,
    event_status_channel_halt      => open,
    event_data_in_channel_halt     => open,
    event_data_out_channel_halt    => open
  );

  -- Calculate the power of the complex FFT samples (and infer two DSPs)
  fft_mag_sq_proc : process(clk) is
  begin
    if rising_edge(clk) then
      fft_out_re_r        <= fft_out_re;
      fft_out_im_r        <= fft_out_im;
      fft_out_valid_r     <= fft_out_valid;
      fft_out_last_r      <= fft_out_last;

      fft_out_re_rr       <= fft_out_re_r;
      fft_out_im_rr       <= fft_out_im_r;
      fft_out_valid_rr    <= fft_out_valid_r;
      fft_out_last_rr     <= fft_out_last_r;

      fft_re_sq_r         <= signed(fft_out_re_rr) * signed(fft_out_re_rr);
      fft_im_sq_r         <= signed(fft_out_im_rr) * signed(fft_out_im_rr);
      fft_out_valid_rrr   <= fft_out_valid_rr;
      fft_out_last_rrr    <= fft_out_last_rr;

      -- drop a duplicated sign bit
      -- leave the other sign bit to account for bit growth in the add below
      fft_re_sq_rr        <= fft_re_sq_r(fft_re_sq_r'high-1 downto 0);
      fft_im_sq_rr        <= fft_im_sq_r(fft_im_sq_r'high-1 downto 0);
      fft_out_valid_r4    <= fft_out_valid_rrr;
      fft_out_last_r4     <= fft_out_last_rrr;

      fft_mag_sq_ur       <= unsigned(fft_re_sq_rr + fft_im_sq_rr);
      fft_mag_sq_valid_r  <= fft_out_valid_r4;
      fft_mag_sq_last_r   <= fft_out_last_r4;
    end if;
  end process;

  -- Assign the FFT output samples to the output vector
  output_buf_proc : process(clk) is
  begin
    if rising_edge(clk) then
      output_buf_valid_r <= '0';

      if (fft_mag_sq_valid_r = '1') then
        output_counter_ur <= output_counter_ur - 1;

        if (fft_mag_sq_ur > unsigned(power_threshold_in)) then
          output_buf_r(to_integer(output_counter_ur)) <= '1';
        else
          output_buf_r(to_integer(output_counter_ur)) <= '0';
        end if;

        if (fft_mag_sq_last_r = '1') then
          -- Put FFT sample 0 (DC) in output_buf_r(8) to achieve a symmetrical spectrum plot
          -- on the output_vector centred about output(8).
          output_counter_ur   <= to_unsigned(8, output_counter_ur'length);
          output_buf_valid_r  <= '1';
        end if;
      end if;
    end if;
  end process;

  output_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if (output_buf_valid_r = '1') then
        peaks_out <= output_buf_r;
      end if;
    end if;
  end process;

end architecture;
