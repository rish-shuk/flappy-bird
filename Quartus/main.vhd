-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"
-- CREATED		"Sat May 20 16:09:20 2023"

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

LIBRARY work;

ENTITY main IS 
	PORT
	(
		clk :  IN  STD_LOGIC;
		pb2 :  IN  STD_LOGIC;
		PUSH_BUTTON_1 : IN STD_LOGIC;
		SWITCH_1 : IN STD_LOGIC;
		PS2_DAT :  INOUT  STD_LOGIC;
		PS2_CLK :  INOUT  STD_LOGIC;
		red_out :  OUT  STD_LOGIC_VECTOR(3 downto 0);
		green_out :  OUT  STD_LOGIC_VECTOR(3 downto 0);
		blue_out :  OUT  STD_LOGIC_VECTOR(3 downto 0);
		horiz_sync_out :  OUT  STD_LOGIC;
		vert_sync_out :  OUT  STD_LOGIC;
		collision_signal : OUT STD_LOGIC;
		tens: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		ones : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		hundreds : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END main;

ARCHITECTURE bdf_type OF main IS 

COMPONENT vga_sync
	PORT(clock_25Mhz : IN STD_LOGIC;
		 red : IN STD_LOGIC_VECTOR(3 downto 0);
		 green : IN STD_LOGIC_VECTOR(3 downto 0);
		 blue : IN STD_LOGIC_VECTOR(3 downto 0);
		 red_out : OUT STD_LOGIC_VECTOR(3 downto 0);
		 green_out : OUT STD_LOGIC_VECTOR(3 downto 0);
		 blue_out : OUT STD_LOGIC_VECTOR(3 downto 0);
		 horiz_sync_out : OUT STD_LOGIC;
		 vert_sync_out : OUT STD_LOGIC;
		 pixel_column : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 pixel_row : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END COMPONENT;

COMPONENT char_selector
	PORT(
            clk, vert_sync                                              : in std_logic;
            char_adr_in                                                 : in std_logic_vector(5 downto 0);
            char_size                                                   : in std_logic_vector(2 downto 0);
            char_position_x, char_position_y, pixel_row, pixel_column   : in std_logic_vector(9 downto 0);
		    character_address		                                    : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
            font_row, font_col                                          : OUT std_logic_vector(2 downto 0)
	);
END COMPONENT;

COMPONENT char_rom_modified
	PORT(clock : IN STD_LOGIC;
		 character_address : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 font_col : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 font_row : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 rom_mux_output : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mouse
	PORT(clock_25Mhz : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 mouse_data : INOUT STD_LOGIC;
		 mouse_clk : INOUT STD_LOGIC;
		 left_button : OUT STD_LOGIC;
		 right_button : OUT STD_LOGIC;
		 mouse_cursor_column : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 mouse_cursor_row : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pipes
	PORT
		(
		vert_sync								: IN std_logic;
		state : IN std_logic_vector(2 downto 0);
      	pixel_row, pixel_column					: IN std_logic_vector(9 DOWNTO 0);
		hundreds_score : in std_logic_vector(3 downto 0);
			tens_score: IN std_logic_vector(3 downto 0);
		pipe_signal								: OUT std_logic;
		bonus2_collision_signal_in 				: IN std_logic;
		pipe1_x_pos_out 						: OUT std_logic_vector(10 DOWNTO 0);
		pipe2_x_pos_out 						: OUT std_logic_vector(10 DOWNTO 0)
		);
END COMPONENT;

COMPONENT bonus
	PORT
		(
		vert_sync						: IN std_logic;
		state : in std_logic_vector(2 downto 0);
      	pixel_row						: IN std_logic_vector(9 DOWNTO 0);
		pixel_column					: IN std_logic_vector(9 DOWNTO 0);
		bonus1_signal 					: OUT std_logic;
		bonus2_signal 					: OUT std_logic
		);
END COMPONENT;

COMPONENT collisions is
    PORT(
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ball_signal : IN STD_LOGIC;
        pipe_signal : IN STD_LOGIC;
        bonus1_signal : IN STD_LOGIC;
        bonus2_signal : IN STD_LOGIC;
        pipe_collision : OUT STD_LOGIC;
        bonus1_collision : OUT STD_LOGIC;
        bonus2_collision : OUT STD_LOGIC
    );
END COMPONENT;

COMPONENT score_tracker is
    port (
        clk : in std_logic;
        reset : in std_logic;
        state : in std_logic_vector(2 downto 0);
        ball_x_pos : in std_logic_vector(10 downto 0);
        pipe1_x_pos : in std_logic_vector(10 downto 0);
        pipe2_x_pos : in std_logic_vector(10 downto 0);
        ones_score_out : out std_logic_vector(3 downto 0);
        tens_score_out : out std_logic_vector(3 downto 0);
		hundreds_score_out : out std_logic_vector(3 downto 0)
    );
end COMPONENT;

COMPONENT display_mux_4to1
	port(
     clk                : in std_logic;
     ball_signal        : in std_logic;
     ground_signal      : in std_logic;
     background_signal  : in std_logic;
     pipe_signal        : in std_logic;
     bonus1_signal      : in std_logic;
     bonus2_signal      : in std_logic;       
	 text_rgb, border_rgb, bird_rgb, hp_bar_rgb                  : in std_logic_vector(11 downto 0);   
     Red, Green, Blue   : out std_logic_vector(3 downto 0)
  );
END COMPONENT;

COMPONENT bouncy_ball
	PORT( 
		pb1				: IN std_logic;
		clk				: IN std_logic;
		vert_sync		: IN std_logic;
		state : in std_logic_vector(2 downto 0);
		gameReset : in std_logic;
        ground_height	: IN std_logic_vector(9 DOWNTO 0);
		pixel_row 		: IN std_logic_vector(9 DOWNTO 0);	
		pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		ball_signal 	: OUT std_logic;
		bird_y_position : out std_logic_vector(9 downto 0);
		birdPerish : out std_logic
		);
END COMPONENT;

COMPONENT BCD_to_SevenSeg is
     port (BCD_digit : in std_logic_vector(3 downto 0);
           SevenSeg_out : out std_logic_vector(6 downto 0));
end COMPONENT;

COMPONENT background
	PORT(		 
		background_signal : OUT std_logic
	);
END COMPONENT;

COMPONENT pll
	PORT(refclk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 outclk_0 : OUT STD_LOGIC;
		 locked : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT ground
	PORT( 
		pixel_row		: IN std_logic_vector(9 DOWNTO 0);
		pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		ground_signal 	: OUT std_logic;
        ground_height	: OUT std_logic_vector(9 DOWNTO 0)
		);		
END COMPONENT;

COMPONENT state_machine
    PORT
        ( clk, vert_sync,reset   : IN std_logic;
			 deadCheck, SWITCH_GAME, PUSH_BUTTON       : IN std_logic;
			 state : OUT std_logic_vector(2 downto 0);
			 gameReset : out std_logic);
END COMPONENT;

COMPONENT sprite_rom
	PORT
	(
		bird_y_position         :   in std_logic_vector(9 downto 0);
		pixel_row, pixel_column	:	IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock, vert_sync				: 	IN STD_LOGIC ;
		rom_mux_output		:	OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ui
	PORT
		(
            ones_score_in : in std_logic_vector(3 downto 0);
            tens_score_in : in std_logic_vector(3 downto 0);
            hundreds_score_in : in std_logic_vector(3 downto 0);
			health_points								 : in std_Logic_vector(9 downto 0);
		    clk, vert_sync                       : in std_logic;
			 switch : in std_logic;
			 state : in std_logic_vector(2 downto 0);
		    pixel_row, pixel_column 			 : in std_logic_vector(9 downto 0);
            char_adr_out                         : out std_logic_vector(5 downto 0);
            char_size                           : out std_logic_vector(2 downto 0);
            char_position_x_out, char_position_y_out	: out std_logic_vector(9 downto 0);
            hp_bar_rgb		                     : OUT std_logic_vector(11 downto 0)
          );		
END COMPONENT;

COMPONENT border
	PORT
		( pixel_row, pixel_column	                : IN std_logic_vector(9 DOWNTO 0);
		  border_rgb 			                    : OUT std_logic_vector(11 DOWNTO 0)
          );		
END COMPONENT;

COMPONENT health
	port(
        clk, vert_sync : in std_logic;
        reset : in std_logic;
		  state: in std_logic_vector(2 downto 0);
        collision_signal_in, birdPerish : in std_logic;
        bonus1_collision_signal_in : in std_logic;
		  deadCheck : out std_logic;
        health_points : out std_logic_vector(9 downto 0)
    );
END COMPONENT;

SIGNAL	clk_out :  STD_LOGIC;
SIGNAL	ground_height :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	pixel_column :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	pixel_row :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL 	ball_signal 		: std_logic;
SIGNAL 	ground_signal 		: std_logic;
SIGNAL 	background_signal 	: std_logic;
SIGNAL 	pipe_signal 		: std_logic; 
SIGNAL 	bonus1_signal 		: std_logic;
SIGNAL 	bonus2_signal 		: std_logic;
SIGNAL 	pipe1_x_pos_out 	: std_logic_vector(10 DOWNTO 0);
SIGNAL	pipe2_x_pos_out 	: std_logic_vector(10 DOWNTO 0);
SIGNAL 	ones_score_out 		: std_logic_vector(3 downto 0);
SIGNAL  tens_score_out 		: std_logic_vector(3 downto 0);
SIGNAL  hundreds_score_out 	: std_logic_vector(3 downto 0);
SIGNAL 	text_rgb : std_logic_vector(11 downto 0);
SIGNAL	vert_sync :  STD_LOGIC;
SIGNAL  character_address : STD_LOGIC_VECTOR (5 DOWNTO 0);
SIGNAL	red_value :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	green_value :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	blue_value :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	gnd :  STD_LOGIC;
SIGNAL	mouse_left_button :  STD_LOGIC;
SIGNAL	deadCheck : STD_LOGIC;
SIGNAL  bird_rgb : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL  font_row, font_col : std_logic_vector(2 downto 0);
signal currentState : std_logic_vector(2 downto 0);
signal birdPerish : std_logic;
signal gameReset : std_logic;
-- menu_text
SIGNAL  char_adr_in : std_logic_vector(5 downto 0);
SIGNAL  char_size    : std_logic_vector(2 downto 0);
SIGNAL  char_position_x_menu_text, char_position_y_menu_text	: std_logic_vector(9 downto 0);
SIGNAl  bird_y_position : std_logic_vector(9 downto 0);
signal hp_bar_rgb : STD_LOGIC_VECTOR(11 DOWNTO 0);
signal border_rgb : std_logic_vector(11 downto 0);
signal health_points :  std_logic_vector(9 downto 0);
signal pipe_collision_signal_out : std_logic;
signal bonus1_collision_signal_out : std_logic;
signal bonus2_collision_signal_out : std_logic;


BEGIN 
gnd <= '0';

VGA: vga_sync
PORT MAP(clock_25Mhz => clk_out,
		 red => red_value,
		 green => green_value,
		 blue => blue_value,
		 red_out => red_out,
		 green_out => green_out,
		 blue_out => blue_out,
		 horiz_sync_out => horiz_sync_out,
		 vert_sync_out => vert_sync,
		 pixel_column => pixel_column,
		 pixel_row => pixel_row);

CHARROM: char_rom_modified
PORT MAP(
		 character_address => character_address,
		 font_col => font_col,
		 font_row => font_row,
		 clock => clk_out,
		 rom_mux_output => text_rgb);

STATEMACHINE : state_machine
PORT MAP(clk => clk_out,
			vert_sync => vert_sync,
			deadCheck => deadCheck,
			state => currentState,
			reset => gnd,
			gameReset => gameReset,
			SWITCH_GAME => SWITCH_1,
			PUSH_BUTTON => PUSH_BUTTON_1);

PIPE1: pipes
PORT MAP(vert_sync => vert_sync,
			state => currentState,
			pixel_row => pixel_row,
			pixel_column => pixel_column,
			pipe_signal => pipe_signal,
			bonus2_collision_signal_in => bonus2_collision_signal_out,
			pipe1_x_pos_out => pipe1_x_pos_out,
			hundreds_score => hundreds_score_out,
			tens_score => tens_score_out,
			pipe2_x_pos_out => pipe2_x_pos_out);

B1: bonus
PORT MAP
		(
		vert_sync => vert_sync,
		state => currentState,
      	pixel_row => pixel_row,
		pixel_column => pixel_column,
		bonus1_signal => bonus1_signal,
		bonus2_signal => bonus2_signal
	);



COL: collisions
    PORT MAP(
        clk => clk_out,
        reset => gnd,
        ball_signal => ball_signal,
        pipe_signal => pipe_signal,
        pipe_collision => pipe_collision_signal_out,
		bonus1_signal => bonus1_collision_signal_out,
		bonus2_signal => bonus2_collision_signal_out
    );


SCORE_TRK: score_tracker
PORT MAP(clk => clk_out,
		reset => gameReset,
		state => currentState,
		ball_x_pos => CONV_STD_LOGIC_VECTOR(320,11),
        pipe1_x_pos => pipe1_x_pos_out,
        pipe2_x_pos => pipe2_x_pos_out,
        ones_score_out => ones_score_out,
		tens_score_out => tens_score_out,
		hundreds_score_out => hundreds_score_out
);

BCD1: BCD_to_SevenSeg
PORT MAP(
	BCD_digit => ones_score_out,
	SevenSeg_out => ones
);

BCD2: BCD_to_SevenSeg
PORT MAP(
	BCD_digit => tens_score_out,
	SevenSeg_out => tens
);

BCD3: BCD_to_SevenSeg
PORT MAP(
	BCD_digit => hundreds_score_out,
	SevenSeg_out => hundreds
);


MSE: mouse
PORT MAP(clock_25Mhz => clk_out,
		 reset => gnd,
		 mouse_data => PS2_DAT,
		 mouse_clk => PS2_CLK,
		 left_button => mouse_left_button);


DISPLAYMUX: display_mux_4to1
PORT MAP(clk => clk_out,
		 ball_signal => ball_signal,
		 ground_signal => ground_signal,
		 background_signal => background_signal,
		 pipe_signal => pipe_signal,
		 bonus1_signal => bonus1_signal,
		 bonus2_signal => bonus2_signal,
		 text_rgb => text_rgb,
		 border_rgb => border_rgb,
		 bird_rgb => bird_rgb,
		 hp_bar_rgb => hp_bar_rgb,
		 Red => red_value,
		 Green => green_value,
		 Blue => blue_value);


BALL: bouncy_ball
PORT MAP(pb1 => mouse_left_button,
		 clk => clk_out,
		 vert_sync => vert_sync,
		 state => currentState,
		 gameReset => gameReset,
		 ground_height => ground_height,
		 pixel_column => pixel_column,
		 pixel_row => pixel_row,
		 ball_signal => ball_signal,
		 bird_y_position => bird_y_position,
		 birdPerish => birdPerish
		 );

BG: background
PORT MAP(background_signal => background_signal);

CLKDIVIDER: pll
PORT MAP(refclk => clk,
		 rst => gnd,
		 outclk_0 => clk_out);

GAMEGND: ground
PORT MAP(pixel_column => pixel_column,
		 pixel_row => pixel_row,
		 ground_height => ground_height
		 );

SPRITEROM: sprite_rom
PORT MAP(
		bird_y_position => bird_y_position,
		pixel_column => pixel_column,
		pixel_row => pixel_row,
		clock => clk_out,
		vert_sync => vert_sync,
		rom_mux_output => bird_rgb
		);

UI_TEXT: ui
PORT MAP (
		ones_score_in => ones_score_out,
		tens_score_in => tens_score_out,
		hundreds_score_in => hundreds_score_out,
		health_points => health_points,
		clk => clk_out,
		vert_sync => vert_sync,
		pixel_row => pixel_row,
		pixel_column => pixel_column,
		char_adr_out => char_adr_in,
		char_size => char_size,
		char_position_x_out => char_position_x_menu_text,
		char_position_y_out => char_position_y_menu_text,
		hp_bar_rgb => hp_bar_rgb,
		switch => SWITCH_1,
		state => currentState
);

CHARSELECTOR: char_selector
PORT MAP(
			clk => clk_out,
			vert_sync => vert_sync,
			char_adr_in => char_adr_in,
			char_size => char_size,
			char_position_x => char_position_x_menu_text,
			char_position_y => char_position_y_menu_text,
			pixel_row => pixel_row,
			pixel_column => pixel_column,
			character_address => character_address,
			font_row => font_row,
			font_col => font_col
);

UI_BORDER: border
port map(
	pixel_row => pixel_row,
	pixel_column => pixel_column,
	border_rgb => border_rgb
);

POINTS_HEALTH: health
port map (
		clk => clk_out,
		vert_sync => vert_sync,
        reset => gameReset, 
        collision_signal_in => pipe_collision_signal_out,
		  state => currentState,
		bonus1_collision_signal_in => bonus1_collision_signal_out,
		birdPerish => birdPerish,
		deadCheck => deadCheck,
        health_points => health_points
);

vert_sync_out <= vert_sync;

END bdf_type;