library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY bonus IS
	PORT
		(
		vert_sync			: IN std_logic;
		state : in std_logic_vector(2 downto 0);
      	pixel_row, pixel_column			: IN std_logic_vector(9 DOWNTO 0);
		bonus1_signal					: OUT std_logic;
        bonus2_signal                   : OUT std_logic
		);
		  		
end bonus;

architecture behavior of bonus is

type height_array is array (0 to 9) of integer;

-- Constants
constant SCREEN_MAX_WIDTH 		: std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(639,11); 
constant SCREEN_HALFWAY_WIDTH 	: std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(320,11); 
constant BONUS_SIZE 			: std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(8,11);
constant RAND_HEIGHT_ARRAY 		: height_array := (5, 25, 50, 90, 110, 150, 190, 220, 270, 290); -- random heights for pipes (0 to 9)
constant START_POS_1			: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(720,11); 	-- Initial pipe position
constant START_POS_2			: std_logic_vector(10 DOWNTO 0) := SCREEN_MAX_WIDTH + SCREEN_HALFWAY_WIDTH + CONV_STD_LOGIC_VECTOR(50,11); 	-- Initial pipe position


constant idx_seed : std_logic_vector(15 downto 0) := CONV_STD_LOGIC_VECTOR(43690, 16);
constant idx_polynom : std_logic_vector(15 downto 0) := CONV_STD_LOGIC_VECTOR(21845, 16);
-- Signals

SIGNAL bonus1_on					: std_logic;
SIGNAL bonus2_on					: std_logic;
SIGNAL bonus1_x_pos				    : std_logic_vector(10 DOWNTO 0) := START_POS_1; 	-- Initial bonus position
SIGNAL bonus2_x_pos				    : std_logic_vector(10 DOWNTO 0) := START_POS_2; 	-- Initial pipe position
SIGNAL bonus1_y_pos                 : std_logic_vector(10 DOWNTO 0);
SIGNAL bonus2_y_pos                 : std_logic_vector(10 DOWNTO 0);

SIGNAL bonus_x_motion			: std_logic_vector(9 DOWNTO 0);

SIGNAL random_index			: std_logic_vector(15 downto 0);
SIGNAL current_idx			: integer;
SIGNAL appear_idx			: integer;
SIGNAL idx_reset			: std_logic;

COMPONENT random_idx is
    port (
        clk     : in std_logic;
        reset   : in std_logic;
        seed    : in std_logic_vector(15 downto 0);
        polynom : in std_logic_vector(15 downto 0);
        random_num  : out std_logic_vector(15 downto 0)
    );
END COMPONENT;

BEGIN  

	RNG : random_idx
        PORT MAP (
			clk => vert_sync,
			reset => idx_reset, 
			seed => idx_seed,
			polynom => idx_polynom,
			random_num => random_index
			);

	-- Pipe 1 should only be on the screen when it is between 0 and max width
	bonus1_on <= '1' when (
		((bonus1_x_pos <= pixel_column + bonus_size) 
		and (pixel_column <= bonus1_x_pos + bonus_size) 	
		and (bonus1_y_pos <= pixel_row + bonus_size) and (pixel_row <= bonus1_y_pos + bonus_size)))
		else '0';

	-- Pipe 2 should only be on the screen when it is between 0 and max width
	bonus2_on <= '1' when (
		((bonus2_x_pos <= pixel_column + bonus_size) 
		and (pixel_column <= bonus2_x_pos + bonus_size) 	
		and (bonus2_y_pos < pixel_row + bonus_size) and (pixel_row <= bonus2_y_pos + bonus_size)))
		else '0';

	bonus1_signal <= bonus1_on;
    bonus2_signal <= bonus2_on;

	current_idx <= ieee.numeric_std.to_integer(ieee.numeric_std.unsigned(random_index)) mod 9;
    appear_idx <= ieee.numeric_std.to_integer(ieee.numeric_std.unsigned(random_index)) mod 2;
    


	Move_bonus: process (vert_sync)  	
	begin
		-- Move pipe once every vertical sync
		if (rising_edge(vert_sync)) then

			-- Move pipe 1
			if(state = "001" or state = "010") then
				bonus_x_motion <= CONV_STD_LOGIC_VECTOR(3,10);
				bonus1_x_pos <= bonus1_x_pos - bonus_x_motion;
				bonus2_x_pos <= bonus2_x_pos - bonus_x_motion;

				-- Reset bonus 1 position
				if (bonus1_x_pos < bonus_x_motion and appear_idx = 1) then
					bonus1_x_pos <= SCREEN_MAX_WIDTH + bonus_size;
					bonus1_y_pos <= CONV_STD_LOGIC_VECTOR(RAND_HEIGHT_ARRAY(current_idx),11);
				end if;

				-- Reset pipe 2 position
				if (bonus2_x_pos < bonus_x_motion and appear_idx = 1) then
					bonus2_x_pos <= SCREEN_MAX_WIDTH + bonus_size;
					bonus2_y_pos <= CONV_STD_LOGIC_VECTOR(RAND_HEIGHT_ARRAY(current_idx),11);
				end if;
			end if;
			
			
		end if;
	end process Move_bonus;

END architecture behavior;