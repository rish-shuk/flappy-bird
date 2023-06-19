library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY pipes IS
	PORT
		(
		vert_sync					: IN std_logic;
		state : IN std_logic_vector(2 downto 0);
      	pixel_row, pixel_column					: IN std_logic_vector(9 DOWNTO 0);
			bonus2_collision_signal_in 				: IN std_logic;
			hundreds_score : in std_logic_vector(3 downto 0);
			tens_score : in std_logic_vector(3 downto 0);
			pipe_signal								: OUT std_logic;
		pipe1_x_pos_out 						: OUT std_logic_vector(10 DOWNTO 0);
		pipe2_x_pos_out 						: OUT std_logic_vector(10 DOWNTO 0)
		);
		  		
end pipes;

architecture behavior of pipes is

type height_array is array (0 to 9) of integer;

-- Constants
constant SCREEN_MAX_WIDTH 		: std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(639,11); 
constant SCREEN_HALFWAY_WIDTH 	: std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(320,11); 
constant PIPE_WIDTH 			: std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(25,11);
constant PIPE_GAP				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(100,10); 	-- gap between pipes
constant PIPE_SPACING 			: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200,11); 	-- space between pipes
constant RAND_HEIGHT_ARRAY 		: height_array := (5, 25, 50, 90, 110, 150, 190, 220, 270, 290); -- random heights for pipes (0 to 9)
constant START_POS_1			: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(690,11); 	-- Initial pipe position
constant START_POS_2			: std_logic_vector(10 DOWNTO 0) := SCREEN_MAX_WIDTH + SCREEN_HALFWAY_WIDTH + CONV_STD_LOGIC_VECTOR(50,11); 	-- Initial pipe position


constant idx_seed : std_logic_vector(15 downto 0) := CONV_STD_LOGIC_VECTOR(43690, 16);
constant idx_polynom : std_logic_vector(15 downto 0) := CONV_STD_LOGIC_VECTOR(21845, 16);
-- Signals
SIGNAL pipe1_on					: std_logic;
SIGNAL pipe2_on					: std_logic;
SIGNAL pipe1_height 			: std_logic_vector(9 DOWNTO 0); 
SIGNAL pipe2_height 			: std_logic_vector(9 DOWNTO 0); 
SIGNAL pipe1_x_pos				: std_logic_vector(10 DOWNTO 0) := START_POS_1; 	-- Initial pipe position
SIGNAL pipe2_x_pos				: std_logic_vector(10 DOWNTO 0) := START_POS_2; 	-- Initial pipe position


SIGNAL pipe_x_motion			: std_logic_vector(9 DOWNTO 0);
SIGNAL enable 					: std_logic;

SIGNAL random_index			: std_logic_vector(15 downto 0);
SIGNAL current_idx			: integer;
SIGNAL idx_reset			: std_logic;
signal convertedTens : std_logic_vector(9 downto 0);

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
	pipe1_on <= '1' when (
		((pipe1_x_pos <= pixel_column + PIPE_WIDTH) 
		and (pixel_column <= pipe1_x_pos + PIPE_WIDTH) 	
		and (pipe1_height + PIPE_GAP < pixel_row))								
		or
		((pipe1_x_pos <= pixel_column + PIPE_WIDTH) 
		and (pixel_column <= pipe1_x_pos + PIPE_WIDTH) 	
		and (pipe1_height > pixel_row))) 
		else '0';

	-- Pipe 2 should only be on the screen when it is between 0 and max width
	pipe2_on <= '1' when (
		((pipe2_x_pos <= pixel_column + PIPE_WIDTH) 
		and (pixel_column <= pipe2_x_pos + PIPE_WIDTH) 	
		and (pipe2_height + PIPE_GAP < pixel_row))								
		or
		((pipe2_x_pos <= pixel_column + PIPE_WIDTH) 
		and (pixel_column <= pipe2_x_pos + PIPE_WIDTH) 	
		and (pipe2_height > pixel_row))) 
		else '0';

	pipe_signal <= pipe1_on or pipe2_on;
	pipe1_x_pos_out <= pipe1_x_pos;
	pipe2_x_pos_out <= pipe2_x_pos;
	current_idx <= ieee.numeric_std.to_integer(ieee.numeric_std.unsigned(random_index)) mod 9;


	Move_pipe: process (vert_sync)  
		variable counter : integer := 0;
		variable counter_fin : integer := 50;
	begin
		-- Move pipe once every vertical sync
		if (rising_edge(vert_sync)) then

			-- Move pipe 1 when in PLAY TRAIN state
			if(state = "010" or state = "001") then	
				-- IN PLAY
				if state = "010" then
					convertedTens <= "00" & hundreds_score & tens_score;
					pipe_x_motion <= CONV_STD_LOGIC_VECTOR(2,10) + convertedTens;
				else
					pipe_x_motion <= CONV_STD_LOGIC_VECTOR(2,10);
				end if;

				pipe1_x_pos <= pipe1_x_pos - pipe_x_motion;
				pipe2_x_pos <= pipe2_x_pos - pipe_x_motion;

				-- Reset pipe 1 position
				if (pipe1_x_pos < pipe_x_motion) then
					pipe1_x_pos <= SCREEN_MAX_WIDTH + PIPE_WIDTH;
					pipe1_height <= CONV_STD_LOGIC_VECTOR(RAND_HEIGHT_ARRAY(current_idx),10);
				end if;

				-- Reset pipe 2 position
				if (pipe2_x_pos < pipe_x_motion) then
					pipe2_x_pos <= SCREEN_MAX_WIDTH + PIPE_WIDTH;
					pipe2_height <= CONV_STD_LOGIC_VECTOR(RAND_HEIGHT_ARRAY(current_idx),10);
				end if;
			-- WHEN DEAD
			elsif (state = "011") then 
				pipe1_x_pos <= START_POS_1;
				pipe2_x_pos <= START_POS_2;
			end if;
			
			
		end if;
	end process Move_pipe;

END architecture behavior;