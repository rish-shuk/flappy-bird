LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY border IS
	PORT
		( pixel_row, pixel_column	                : IN std_logic_vector(9 DOWNTO 0);
		  border_rgb 			                    : OUT std_logic_vector(11 DOWNTO 0)
          );		
END border;

architecture behavior of border is
  
SIGNAL border_on, border_top, border_left, border_right, border_bottom : std_logic;
SIGNAL border_heightPosition : std_logic_vector(9 downto 0);
BEGIN           

border_top <= '1' when (((CONV_STD_LOGIC_VECTOR(0,10)) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(32,10))
) else '0';

border_left <= '1' when (
    ((CONV_STD_LOGIC_VECTOR(0, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(32,10))) and 
    ((CONV_STD_LOGIC_VECTOR(0,10)) <= pixel_row) and (pixel_row  <= CONV_STD_LOGIC_VECTOR(480,10))
) else '0';

border_right <= '1' when (
    ((CONV_STD_LOGIC_VECTOR(608, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(640,10))) and 
    ((CONV_STD_LOGIC_VECTOR(0,10)) <= pixel_row) and (pixel_row  <= CONV_STD_LOGIC_VECTOR(480,10))
) else '0';
    
border_bottom <= '1' when (
    -- (CONV_STD_LOGIC_VECTOR(32, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(608,10)) and 
    (CONV_STD_LOGIC_VECTOR(420,10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(480,10))
) else '0';

border_on <= '1' when (border_top = '1' or border_left = '1' or border_right = '1' or border_bottom ='1') else '0';

-- set colors
border_rgb(11 downto 8) <= border_bottom & border_bottom & border_bottom & border_bottom;
border_rgb(7 downto 4) <= border_bottom & '0' & '0' & '0';
border_rgb(2) <= '0';
border_rgb(1) <= border_on;
border_rgb(0) <= '0';

-- set outputs

END behavior;

