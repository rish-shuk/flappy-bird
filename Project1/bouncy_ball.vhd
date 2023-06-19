LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY bouncy_ball IS
	PORT
		( pb1, clk, vert_sync	: IN std_logic;
          ground_height, pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
			 state : in std_logic_vector(2 downto 0);
			 gameReset : in std_logic;
		  ball_signal									: OUT std_logic;
		  bird_y_position								: out std_logic_vector(9 downto 0);
		  birdPerish									: out std_logic
		  );		
END bouncy_ball;

architecture behavior of bouncy_ball is

SIGNAL ball_on					: std_logic;
SIGNAL size 					: std_logic_vector(9 DOWNTO 0);  
SIGNAL ball_y_pos				: std_logic_vector(9 DOWNTO 0)  := CONV_STD_LOGIC_VECTOR(160 ,10);
SiGNAL ball_x_pos				: std_logic_vector(10 DOWNTO 0);
SIGNAL ball_y_motion			: std_logic_vector(9 DOWNTO 0);
SIGNAL prevButton				: std_logic;

BEGIN           

size <= CONV_STD_LOGIC_VECTOR(8,10);
-- ball_x_pos and ball_y_pos show the (x,y) for the centre of ball
ball_x_pos <= CONV_STD_LOGIC_VECTOR(320,11);

ball_on <= '1' when ( ('0' & ball_x_pos <= '0' & pixel_column + size) and ('0' & pixel_column <= '0' & ball_x_pos + size) 	-- x_pos - size <= pixel_column <= x_pos + size
					and ('0' & ball_y_pos <= pixel_row + size) and ('0' & pixel_row <= ball_y_pos + size) )  else	-- y_pos - size <= pixel_row <= y_pos + size
			'0';

ball_signal <= ball_on;

-- Off the ground
--ground_height <= CONV_STD_LOGIC_VECTOR(420,10);
--ground_on <= '1' when (pixel_row > ground_height) else '0';
-- ground_on <= '1' when (pixel_column else '0');


Move_Ball: process (vert_sync)
-- Use variable to increase speed overtime
variable ball_acc:integer range 0 to 11 := 0;
variable soar:integer range 0 to 7 := 0;
variable over:std_logic := '0';
variable varMotion : std_logic_vector(9 downto 0);
variable varYPos : std_logic_vector(9 downto 0);
begin
	if gameReset = '1' then
			ball_y_pos <= CONV_STD_LOGIC_VECTOR(160,10);
	-- Move ball once every vertical sync
	elsif (rising_edge(vert_sync)) then	
		if (state = "010" or state = "001") then
			-- Button pressed, fly
			if ((pb1 = '0') and (prevButton = '0')) then
				ball_acc := 0;
				prevButton <= '1';
				ball_y_motion <= - CONV_STD_LOGIC_VECTOR(12 ,10);
				soar := 1;
				over := '0';
			-- Reaches roof
			elsif (ball_y_pos <= CONV_STD_LOGIC_VECTOR(20,10) + size) then
				ball_y_pos <= CONV_STD_LOGIC_VECTOR(20,10) + size;
				if ball_acc /= CONV_STD_LOGIC_VECTOR(6,10) then
					ball_acc := (ball_acc + 1);
				else
					null;
				end if;
				ball_y_motion <= CONV_STD_LOGIC_VECTOR(ball_acc,10);
				soar := 0;
				
			-- In Flight acceleration counter
			elsif soar > 0 and soar /= 5 then
				ball_y_motion <= - CONV_STD_LOGIC_VECTOR(12 ,10);
				soar := soar + 1;
			-- Mouse hold
			elsif (((pb1 = '0') and prevButton = '1')) then
				-- Reaches ground
				if (ball_y_pos >= ground_height - size) then
					ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
					over := '1';
				-- In Air
				elsif (ball_y_pos < ground_height - size) then
					ball_y_pos <= CONV_STD_LOGIC_VECTOR(60,10) + size;
					if ball_acc /= CONV_STD_LOGIC_VECTOR(6,10) then
						ball_acc := (ball_acc + 1);
					else
						null;
					end if;
					ball_y_motion <= CONV_STD_LOGIC_VECTOR(ball_acc,10);
				-- Beyond top of screen
				elsif (ball_y_pos <= CONV_STD_LOGIC_VECTOR(20,10) + size) then
					ball_y_pos <= CONV_STD_LOGIC_VECTOR(0,10) + size;
					soar := 0;
				end if;
			-- Reaches ground
			elsif ((ball_y_pos >= ground_height - size) and (pb1 = '1')) then
				ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
				prevButton <= '0';
				over := '1';
			-- In air
			elsif ((ball_y_pos < (ground_height - size)) and (pb1 = '1')) then
				ball_y_pos <= CONV_STD_LOGIC_VECTOR(60,10) + size;
				if ball_acc /= CONV_STD_LOGIC_VECTOR(6,10) then
					ball_acc := (ball_acc + 1);
				else
					null;
				end if;
				ball_y_motion <= CONV_STD_LOGIC_VECTOR(ball_acc,10);
				prevButton <= '0';
			end if;
			-- Compute next ball Y position
			if over /= '1' then
				ball_y_pos <= ball_y_pos + ball_y_motion;
			else 
				ball_y_pos <= ground_height - size;
				ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
				-- INSTANT DEATH
			end if;
		-- When paused or dead, dont move
		elsif state = "100" or state = "011" then
			ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
			ball_y_pos <= ball_y_pos + ball_y_motion;
			over := '0';
		-- back to start screen
		else
			over := '0';
			ball_y_pos <= CONV_STD_LOGIC_VECTOR(160,10);
		end if;
	end if;
	bird_y_position <= ball_y_pos;
	birdPerish <= over;

end process Move_Ball;

END behavior;


