LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY ground IS
	PORT
		( pixel_row, pixel_column	                : IN std_logic_vector(9 DOWNTO 0);
		  ground_signal			                    : OUT std_logic;
          ground_height                             : OUT std_logic_vector(9 DOWNTO 0));		
END ground;

architecture behavior of ground is
  
SIGNAL ground_on : std_logic;
SIGNAL ground_heightPosition : std_logic_vector(9 downto 0);
BEGIN           

-- set size
ground_heightPosition <= CONV_STD_LOGIC_VECTOR(420,10);

-- set ground colors when at row beyond heightposition
ground_on <= '1' when (pixel_row > ground_heightPosition) else '0';

-- set outputs
ground_signal <= ground_on;
ground_height <= ground_heightPosition;

END behavior;

