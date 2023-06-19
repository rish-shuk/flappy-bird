LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY background IS
	PORT
		(
		  background_signal		: OUT std_logic
        );		
END background;

architecture behavior of background is
constant v_bg_signal : std_logic := '1';

BEGIN           
	background_signal <= '1';


-- Colours for pixel data on video signal
-- Keeping background CYAN - R - 0, G - 1, B - 1
-- Red <=  '0';
-- Green <= '1';
-- Blue <=  '1';
-- red 0000 blue 1000 green 1000
--background_rgb <= "110010101001";

END behavior;

