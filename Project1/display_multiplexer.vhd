--https://allaboutfpga.com/vhdl-4-to-1-mux-multiplexer/
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_MISC.all;

entity display_mux_4to1 is
 port(
     clk                : in std_logic;
     ball_signal        : in std_logic;
     ground_signal      : in std_logic;
     background_signal  : in std_logic;
     pipe_signal        : in std_logic;
     bonus1_signal      : in std_logic;
     bonus2_signal       : in std_logic;    
     text_rgb, border_rgb, bird_rgb, hp_bar_rgb                       : in std_logic_vector(11 downto 0);   
     Red, Green, Blue   : out std_logic_vector(3 downto 0)
  );
end display_mux_4to1;
 
architecture behavior of display_mux_4to1 is

signal v_red : std_logic_vector(3 downto 0);
signal v_green : std_logic_vector(3 downto 0);
signal v_blue : std_logic_vector(3 downto 0);
--text
--hp
--border
--ball
--bird
--pipe
--ground
--background
begin
process (clk) is
begin
  if (rising_edge(clk)) then
    -- if (ball_signal = '1') then
    --   -- v_red <= "1111";
    --   -- v_green <= "0000";
    --   -- v_blue <= "0000";
    if (or_reduce(text_rgb) = '1') then
      v_red <= text_rgb(11 downto 8);
      v_green <= text_rgb(7 downto 4);
      v_blue <= text_rgb(3 downto 0);
    elsif (or_reduce(hp_bar_rgb) = '1') then
      v_red <= hp_bar_rgb(11 downto 8);
      v_green <= hp_bar_rgb(7 downto 4);
      v_blue <= hp_bar_rgb(3 downto 0);
    elsif (or_reduce(border_rgb) = '1') then
      v_red <= border_rgb(11 downto 8);
      v_green <= border_rgb(7 downto 4);
      v_blue <= border_rgb(3 downto 0);
    elsif (pipe_signal = '1') then
      v_red <= "0000";
      v_green <= "1101";
      v_blue <= "0100";
    elsif (or_reduce(bird_rgb) = '1') then
      v_red <= bird_rgb(11 downto 8);
      v_green <= bird_rgb(7 downto 4);
      v_blue <= bird_rgb(3 downto 0);
    elsif (bonus1_signal = '1') then
      v_red <= "1111";
      v_green <= "1010";
      v_blue <= "0110";
    elsif (bonus2_signal = '1') then
      v_red <= "1010";
      v_green <= "0101";
      v_blue <= "1001";
    elsif (ground_signal = '1') then
      v_red <= "0000";
      v_green <= "0000";
      v_blue <= "0110";
    else 
      v_red <= "1100";  
      v_green <= "1010";
      v_blue <= "1001";
    end if;
    Red <= v_red;
    Green <= v_green;
    Blue <= v_blue;
  end if;
end process;
end behavior;
