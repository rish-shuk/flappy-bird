LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY ui IS
	PORT
		(
            ones_score_in : in std_logic_vector(3 downto 0);
            tens_score_in : in std_logic_vector(3 downto 0);
            hundreds_score_in : in std_logic_vector(3 downto 0);
            health_points                        : in std_logic_vector(9 downto 0);
		    clk, vert_sync                       : in std_logic;
		    pixel_row, pixel_column 			 : in std_logic_vector(9 downto 0);
			 switch : in std_logic;
			 state : in std_logic_vector(2 downto 0);
            char_adr_out                         : out std_logic_vector(5 downto 0);
            char_size                           : out std_logic_vector(2 downto 0);
            char_position_x_out, char_position_y_out	: out std_logic_vector(9 downto 0);
            hp_bar_rgb		                     : OUT std_logic_vector(11 downto 0)
          );		
END ui;

architecture behavior of ui is
    type alphabet_char_address is array (0 to 25) of std_logic_vector(5 downto 0);
    type char_spacing is array (0 to 10) of std_logic_vector(9 downto 0);

    SIGNAL current_char_addr                      : std_logic_vector(5 downto 0) := CONV_STD_LOGIC_VECTOR(1, 6);
    SIGNAL current_char_pos_x, current_char_pos_y : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
    SIGNAL current_char_size                      : std_logic_vector(2 downto 0) := CONV_STD_LOGIC_VECTOR(2, 3);
    
    SIGNAL alphabet_char_addr_list : alphabet_char_address := ("000001", "000010", "000011", 
    "000100", "000101", "000110", "000111", "001000", "001001", "001010", "001011", "001100",
     "001101", "001110", "001111", "010000", "010001", "010010", "010011", "010100", "010101", 
     "010110", "010111", "011000", "011001", "011010");
    
    SIGNAL char_one_spacing_position                   : char_spacing := (CONV_STD_LOGIC_VECTOR(0, 10),
     CONV_STD_LOGIC_VECTOR(16, 10), CONV_STD_LOGIC_VECTOR(32, 10), CONV_STD_LOGIC_VECTOR(48, 10),
     CONV_STD_LOGIC_VECTOR(64, 10), CONV_STD_LOGIC_VECTOR(80, 10), CONV_STD_LOGIC_VECTOR(96, 10),
     CONV_STD_LOGIC_VECTOR(112, 10), CONV_STD_LOGIC_VECTOR(128, 10), CONV_STD_LOGIC_VECTOR(144, 10), 
     CONV_STD_LOGIC_VECTOR(160  , 10));

    SIGNAL char_two_spacing_position                   : char_spacing := (CONV_STD_LOGIC_VECTOR(0, 10),
     CONV_STD_LOGIC_VECTOR(32, 10), CONV_STD_LOGIC_VECTOR(64, 10), CONV_STD_LOGIC_VECTOR(96, 10),
     CONV_STD_LOGIC_VECTOR(128, 10), CONV_STD_LOGIC_VECTOR(160, 10), CONV_STD_LOGIC_VECTOR(192, 10),
     CONV_STD_LOGIC_VECTOR(224, 10), CONV_STD_LOGIC_VECTOR(256, 10), CONV_STD_LOGIC_VECTOR(288, 10), 
     CONV_STD_LOGIC_VECTOR(320, 10));

    SIGNAL text_one_window_size                        : std_logic_vector(9 downto 0);
    SIGNAL text_two_window_size                        : std_logic_vector(9 downto 0);
    SIGNAL text_one_char_size                          : std_logic_vector(2 downto 0);
    SIGNAL text_two_char_size                          : std_logic_vector(2 downto 0);
    -------------------------------------------------------------------------------------------------------------------------
    -- TITLE MENU
    -------------------------------------------------------------------------------------------------------------------------
    SIGNAL flappy_position                             : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(96, 10);
    signal flappy_f, flappy_l, flappy_a, flappy_p1, 
           flappy_p2, flappy_y                         : std_logic := '0';

    SIGNAL bird_position                               : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(352, 10);
    signal bird_b, bird_i, bird_r, bird_d              : std_logic := '0';

    signal play_position                               : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(256, 10);
    signal play_p, play_l, play_a,
           play_y                                      : std_logic := '0';

    signal train_position                              : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(256, 10);
    signal train_t, train_r, train_a,
           train_i, train_n                            : std_logic := '0';
    
    signal arrow_position                              : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(352, 10);
    signal arrow_up, arrow_down                        : std_logic := '0';

    signal retry_r1, retry_e, retry_t, retry_r2, retry_y : std_logic := '0';
    signal menu_m, menu_e, menu_n, menu_u              : std_logic := '0';

    signal sw0_s, sw0_w, sw0_0                          : std_logic := '0';
    signal uparrow, downarrow                          : std_logic := '0';

    signal key0_k, key0_e, key0_y, key0_0              : std_logic := '0';
    signal select_arrow                                : std_logic := '0';
    -------------------------------------------------------------------------------------------------------------------------
    -- SCORE & LIVES
    -------------------------------------------------------------------------------------------------------------------------
    signal score_position                              : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(544, 10);
    signal score_s, score_c, score_o, score_r, score_e,
           score_colon,
           score_hundreds, score_tens, score_ones      : std_logic := '0';

    signal score_hundreds_address, score_tens_address,
           score_ones_address                          : std_logic_vector(5 downto 0);
    
    signal hp_position                                 : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0,10);
    signal hp_h, hp_p, hp_colon                        : std_logic := '0';
    -------------------------------------------------------------------------------------------------------------------------
    -- GAME OVER & PAUSED
    -------------------------------------------------------------------------------------------------------------------------
    signal gameover_position                           : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(160, 10);
    signal gameover_g, gameover_a, gameover_m, 
           gameover_e1, gameover_o, gameover_v,
           gameover_e2, gameover_r                     : std_logic := '0';

    signal paused_position                             : std_logic_vector(9 downto 0);
    signal paused_p, paused_a, paused_u, paused_s, 
           paused_e, paused_d                          : std_logic := '0';

    -------------------------------------------------------------------------------------------------------------------------
    -- HP BAR
    -------------------------------------------------------------------------------------------------------------------------
    signal bar_on                                      : std_logic;
    signal hp_bar_right_end                            : std_logic_vector(9 downto 0);
    -------------------------------------------------------------------------------------------------------------------------
    -- EMULATING FSM SIGNALS
    -------------------------------------------------------------------------------------------------------------------------
    signal menu_on                                     : std_logic := '0';
    signal game_on                                     : std_logic := '0';
    signal paused_on                                   : std_logic := '0';
    signal gameover_on                                 : std_logic := '0';
    signal play_on                                     : std_logic := '0';
    signal train_on                                    : std_logic := '0';

BEGIN           

--char_adr_in: address of the character you want to display (address table is in OCT but must send 6 bit binary) use CONV_STD_LOGIC_VECTOR(integer converted from oct, 6);
--char_size: character size, can only double its previous size (ranges from 0-7);
--char_position_x or y; char position in the screen starting from its top left pixel in the mif file.
-------------------------------------------------------------------------------------------------------------------------
-- SET TEXT ATTRIBUTES
-------------------------------------------------------------------------------------------------------------------------
text_one_window_size <=  CONV_STD_LOGIC_VECTOR(16, 10);
text_two_window_size <=  CONV_STD_LOGIC_VECTOR(32, 10);
text_one_char_size <=  CONV_STD_LOGIC_VECTOR(1, 3);
text_two_char_size <=  CONV_STD_LOGIC_VECTOR(2, 3);

menu_on <= '1';
play_on <= '0';
train_on <= '0';
gameover_on <= '0';
paused_on <= '0';
-- could just hardcode char_two_spacing?


-------------------------------------------------------------------------------------------------------------------------
-- T I T L E    T I T L E   T I T L E   T I T L E    T I T L E    T I T L E   T I T L E   T I T L E    T I T L E    
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-- TURN FLAPPY ON AT SPECIFIED POSITIONS
-------------------------------------------------------------------------------------------------------------------------
flappy_f <= '1' when (
    (flappy_position <= pixel_column) and (pixel_column <= flappy_position + text_two_window_size) and 
    (flappy_position <= pixel_row) and (pixel_row  <= flappy_position + text_two_window_size)
    ) else '0';

flappy_l <= '1' when (
    (flappy_position + char_two_spacing_position(1) <= pixel_column) and (pixel_column <= flappy_position + char_two_spacing_position(2)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + text_two_window_size)
    ) else '0';

flappy_a <= '1' when (
    (flappy_position + char_two_spacing_position(2) <= pixel_column) and (pixel_column <= flappy_position + char_two_spacing_position(3)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + text_two_window_size)
    ) else '0';

flappy_p1 <= '1' when (
    (flappy_position + char_two_spacing_position(3) <= pixel_column) and (pixel_column <= flappy_position + char_two_spacing_position(4)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + text_two_window_size)
    ) else '0';

flappy_p2 <= '1' when (
    (flappy_position + char_two_spacing_position(4) <= pixel_column) and (pixel_column <= flappy_position + char_two_spacing_position(5)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + text_two_window_size)
    ) else '0';

flappy_y <= '1' when (
    (flappy_position + char_two_spacing_position(5) <= pixel_column) and (pixel_column <= flappy_position + char_two_spacing_position(6)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + text_two_window_size)
    ) else '0';

-------------------------------------------------------------------------------------------------------------------------
-- TURN BIRD ON AT SPECIFIED POSITIONS
-------------------------------------------------------------------------------------------------------------------------
bird_b <= '1' when (
    (bird_position <= pixel_column) and (pixel_column <= bird_position + text_two_window_size) and 
    (flappy_position <= pixel_row) and (pixel_row  <= flappy_position + text_two_window_size)
    ) else '0';

bird_i <= '1' when (
    (bird_position + text_two_window_size <= pixel_column) and (pixel_column <= bird_position + char_two_spacing_position(2)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + text_two_window_size)
    ) else '0';

bird_r <= '1' when (
    (bird_position + char_two_spacing_position(2) <= pixel_column) and (pixel_column <= bird_position + char_two_spacing_position(3)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + text_two_window_size)
    ) else '0';

bird_d <= '1' when (
    (CONV_STD_LOGIC_VECTOR(448,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(480, 10)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + text_two_window_size)
    ) else '0';
-------------------------------------------------------------------------------------------------------------------------
-- T R A I N     A N D     P L A Y     
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-- TURN PLAY ON AT SPECIFIED POSITIONS
-------------------------------------------------------------------------------------------------------------------------
play_p <= '1' when (
    (play_position <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(272, 10)) and 
    (play_position <= pixel_row) and (pixel_row  <= play_position + text_one_window_size)
    ) else '0';

play_l <= '1' when (
    (CONV_STD_LOGIC_VECTOR(272,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(288,10)) and 
    (play_position <= pixel_row) and (pixel_row <= play_position + text_one_window_size)
    ) else '0';

play_a <= '1' when (
    (CONV_STD_LOGIC_VECTOR(288,10)  <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(304,10)) and 
    (play_position <= pixel_row) and (pixel_row <= play_position + text_one_window_size)
    ) else '0';

play_y <= '1' when (
    (CONV_STD_LOGIC_VECTOR(304,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(320, 10)) and 
    (play_position <= pixel_row) and (pixel_row <= play_position + text_one_window_size)
    ) else '0';

sw0_s <= '1' when(
    (CONV_STD_LOGIC_VECTOR(48,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(64, 10)) and 
    (CONV_STD_LOGIC_VECTOR(352,10) <= pixel_row) and (pixel_row  <= CONV_STD_LOGIC_VECTOR(368, 10))
) else '0';

sw0_w <= '1' when(
    (CONV_STD_LOGIC_VECTOR(64,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(80, 10)) and 
    (CONV_STD_LOGIC_VECTOR(352,10) <= pixel_row) and (pixel_row  <= CONV_STD_LOGIC_VECTOR(368, 10))
) else '0';

sw0_0 <= '1' when(
    (CONV_STD_LOGIC_VECTOR(80,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(96, 10)) and 
    (CONV_STD_LOGIC_VECTOR(352,10) <= pixel_row) and (pixel_row  <= CONV_STD_LOGIC_VECTOR(368, 10))
) else '0';

uparrow <= '1' when(
    (CONV_STD_LOGIC_VECTOR(63,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(80, 10)) and 
    (CONV_STD_LOGIC_VECTOR(336,10) <= pixel_row) and (pixel_row  <= CONV_STD_LOGIC_VECTOR(352, 10))
) else '0';

downarrow <= '1' when(
    (CONV_STD_LOGIC_VECTOR(64,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(80, 10)) and 
    (CONV_STD_LOGIC_VECTOR(368,10) <= pixel_row) and (pixel_row  <= CONV_STD_LOGIC_VECTOR(384, 10))
) else '0';

key0_k <= '1' when(
    (CONV_STD_LOGIC_VECTOR(112,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(128, 10)) and 
    (CONV_STD_LOGIC_VECTOR(352,10) <= pixel_row) and (pixel_row  <= CONV_STD_LOGIC_VECTOR(368, 10))
) else '0';

key0_e <= '1' when(
    (CONV_STD_LOGIC_VECTOR(128,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(144, 10)) and 
    (CONV_STD_LOGIC_VECTOR(352,10) <= pixel_row) and (pixel_row  <= CONV_STD_LOGIC_VECTOR(368, 10))
) else '0';

key0_y <= '1' when(
    (CONV_STD_LOGIC_VECTOR(144,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(160, 10)) and 
    (CONV_STD_LOGIC_VECTOR(352,10) <= pixel_row) and (pixel_row  <= CONV_STD_LOGIC_VECTOR(368, 10))
) else '0';

key0_0 <= '1' when(
    (CONV_STD_LOGIC_VECTOR(160,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(176, 10)) and 
    (CONV_STD_LOGIC_VECTOR(352,10) <= pixel_row) and (pixel_row  <= CONV_STD_LOGIC_VECTOR(368, 10))
) else '0';

select_arrow <= '1' when(
    (CONV_STD_LOGIC_VECTOR(176,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(192, 10)) and 
    (CONV_STD_LOGIC_VECTOR(352,10) <= pixel_row) and (pixel_row  <= CONV_STD_LOGIC_VECTOR(368, 10))
) else '0';
----------------------------------------------------------------------------------------------------------
retry_r1 <= '1' when (
    (play_position <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(272, 10)) and 
    (play_position <= pixel_row) and (pixel_row  <= play_position + text_one_window_size)
    ) else '0';

retry_e <= '1' when (
    (CONV_STD_LOGIC_VECTOR(272,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(288,10)) and 
    (play_position <= pixel_row) and (pixel_row <= play_position + text_one_window_size)
    ) else '0';

retry_t <= '1' when (
    (CONV_STD_LOGIC_VECTOR(288,10)  <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(304,10)) and 
    (play_position <= pixel_row) and (pixel_row <= play_position + text_one_window_size)
    ) else '0';

retry_r2 <= '1' when (
    (CONV_STD_LOGIC_VECTOR(304,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(320, 10)) and 
    (play_position <= pixel_row) and (pixel_row <= play_position + text_one_window_size)
    ) else '0';

retry_y <= '1' when (
    (CONV_STD_LOGIC_VECTOR(320,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(336, 10)) and 
    (play_position <= pixel_row) and (pixel_row <= play_position + text_one_window_size)
    ) else '0';
-------------------------------------------------------------------------------------------------------------------------
-- TURN TRAIN ON AT SPECIFIED POSITIONS
-------------------------------------------------------------------------------------------------------------------------
train_t <= '1' when (
    (train_position <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(272, 10)) and 
    (CONV_STD_LOGIC_VECTOR(272, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(288, 10))
    ) else '0';

train_r <= '1' when (
    (CONV_STD_LOGIC_VECTOR(272, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(288, 10)) and 
    (CONV_STD_LOGIC_VECTOR(272, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(288, 10))
    ) else '0';

train_a <= '1' when (
    (CONV_STD_LOGIC_VECTOR(288, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(304, 10)) and 
    (CONV_STD_LOGIC_VECTOR(272, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(288, 10))
    ) else '0';

train_i <= '1' when (
    (CONV_STD_LOGIC_VECTOR(304,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(320, 10)) and 
    (CONV_STD_LOGIC_VECTOR(272, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(288, 10))
    ) else '0';

train_n <= '1' when (
    (CONV_STD_LOGIC_VECTOR(320,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(336, 10)) and 
    (CONV_STD_LOGIC_VECTOR(272, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(288, 10))
    ) else '0';

menu_m <= '1' when (
    (train_position <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(272, 10)) and 
    (CONV_STD_LOGIC_VECTOR(272, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(288, 10))
    ) else '0';

menu_e <= '1' when (
    (CONV_STD_LOGIC_VECTOR(272, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(288, 10)) and 
    (CONV_STD_LOGIC_VECTOR(272, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(288, 10))
    ) else '0';

menu_n <= '1' when (
    (CONV_STD_LOGIC_VECTOR(288, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(304, 10)) and 
    (CONV_STD_LOGIC_VECTOR(272, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(288, 10))
    ) else '0';

menu_u <= '1' when (
    (CONV_STD_LOGIC_VECTOR(304,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(320, 10)) and 
    (CONV_STD_LOGIC_VECTOR(272, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(288, 10))
    ) else '0';

arrow_up <= '1' when ((switch = '1') and
    (arrow_position <= pixel_column) and (pixel_column <= arrow_position + CONV_STD_LOGIC_VECTOR(16, 10)) and 
    (CONV_STD_LOGIC_VECTOR(256, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(272, 10))
    ) else '0';

arrow_down <= '1' when ((switch = '0') and
    (arrow_position <= pixel_column) and (pixel_column <= arrow_position + CONV_STD_LOGIC_VECTOR(16, 10)) and 
    (CONV_STD_LOGIC_VECTOR(272, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(288, 10))
    ) else '0';
-------------------------------------------------------------------------------------------------------------------------
-- G A M E O V E R  A N D   P A U S E D      
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-- TURN GAMEOVER ON AT SPECIFIED POSITIONS
-------------------------------------------------------------------------------------------------------------------------
gameover_g <= '1' when (
    (gameover_position <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(192, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';

gameover_a <= '1' when (
    (CONV_STD_LOGIC_VECTOR(192, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(224, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';

gameover_m <= '1' when (
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(256, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';

gameover_e1 <= '1' when (
    (CONV_STD_LOGIC_VECTOR(256, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(288, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';
--------------------------------------------------------------------------------------------------------------
gameover_o <= '1' when (
    (CONV_STD_LOGIC_VECTOR(320, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(352, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';

gameover_v <= '1' when (
    (CONV_STD_LOGIC_VECTOR(352, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(384, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';

gameover_e2 <= '1' when (
    (CONV_STD_LOGIC_VECTOR(384, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(416, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';

gameover_r <= '1' when (
    (CONV_STD_LOGIC_VECTOR(416, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(448, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';
-------------------------------------------------------------------------------------------------------------------------
-- TURN PAUSED ON AT SPECIFIED POSITIONS
-------------------------------------------------------------------------------------------------------------------------
paused_p <= '1' when (
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(256, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';

paused_a <= '1' when (
    (CONV_STD_LOGIC_VECTOR(256, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(288, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';

paused_u <= '1' when (
    (CONV_STD_LOGIC_VECTOR(288, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(320, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';

paused_s <= '1' when (
    (CONV_STD_LOGIC_VECTOR(320, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(352, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';

paused_e <= '1' when (
    (CONV_STD_LOGIC_VECTOR(352, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(384, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';

paused_d <= '1' when (
    (CONV_STD_LOGIC_VECTOR(384, 10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(416, 10)) and 
    (CONV_STD_LOGIC_VECTOR(224, 10) <= pixel_row) and (pixel_row <= CONV_STD_LOGIC_VECTOR(256, 10))
    ) else '0';
-------------------------------------------------------------------------------------------------------------------------
-- S C O R E   A N D   L I V E S        S C O R E  A N D  L I V E S     
-------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------
-- TURN SCORE ON AT SPECIFIED POSITIONS
-------------------------------------------------------------------------------------------------------------------------
score_hundreds <= '1' when (
    (CONV_STD_LOGIC_VECTOR(544,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(576,10)) and 
    (hp_position <= pixel_row) and (pixel_row <= hp_position + text_two_window_size)
    ) else '0';

score_tens <= '1' when (
    (CONV_STD_LOGIC_VECTOR(576,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(608,10)) and 
    (hp_position <= pixel_row) and (pixel_row <= hp_position + text_two_window_size)
    ) else '0';

score_ones <= '1' when (
    (CONV_STD_LOGIC_VECTOR(608,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(640,10)) and 
    (hp_position <= pixel_row) and (pixel_row <= hp_position + text_two_window_size)
    ) else '0';
--------------------------------------------------
score_s <= '1' when (
    (CONV_STD_LOGIC_VECTOR(352,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(384,10)) and 
    (hp_position <= pixel_row) and (pixel_row <= hp_position + text_two_window_size)
    ) else '0';

score_c <= '1' when (
    (CONV_STD_LOGIC_VECTOR(384,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(416,10)) and 
    (hp_position <= pixel_row) and (pixel_row <= hp_position + text_two_window_size)
    ) else '0';

score_o <= '1' when (
    (CONV_STD_LOGIC_VECTOR(416,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(448,10)) and 
    (hp_position <= pixel_row) and (pixel_row <= hp_position + text_two_window_size)
    ) else '0';

score_r <= '1' when (
    (CONV_STD_LOGIC_VECTOR(448,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(480,10)) and 
    (hp_position <= pixel_row) and (pixel_row <= hp_position + text_two_window_size)
    ) else '0';

-- process(score_e, pixel_row, pixel_column)
--     variable v_score_e : std_logic;
-- begin
--     if ((CONV_STD_LOGIC_VECTOR(480,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(512,10)) and 
--         (hp_position <= pixel_row) and (pixel_row <= hp_position + text_two_window_size)) then
--         v_score_e := '1';
--     else 
--         v_score_e := '0';
--     end if;
--     score_e <= v_score_e;
-- end process;

score_e <= '1' when (
    (CONV_STD_LOGIC_VECTOR(480,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(512,10)) and 
    (hp_position <= pixel_row) and (pixel_row <= hp_position + text_two_window_size)
    ) else '0';

score_colon <= '1' when (
    (CONV_STD_LOGIC_VECTOR(512,10) <= pixel_column) and (pixel_column <= CONV_STD_LOGIC_VECTOR(544,10)) and 
    (hp_position <= pixel_row) and (pixel_row <= hp_position + text_two_window_size)
    ) else '0';

-------------------------------------------------------------------------------------------------------------------------
-- TURN LIVES ON AT SPECIFED POSITIONS
-------------------------------------------------------------------------------------------------------------------------
hp_h <= '1' when (
    (hp_position <= pixel_column) and (pixel_column <= hp_position + text_two_window_size) and 
    (hp_position <= pixel_row) and (pixel_row  <= hp_position + text_two_window_size)
    ) else '0';

hp_p <= '1' when (
    (hp_position + text_two_window_size <= pixel_column) and (pixel_column <= hp_position + char_two_spacing_position(2)) and 
    (hp_position <= pixel_row) and (pixel_row <= hp_position + text_two_window_size)
    ) else '0';

hp_colon <= '1' when (
    (hp_position + char_two_spacing_position(2) <= pixel_column) and (pixel_column <= hp_position + char_two_spacing_position(3)) and 
    (hp_position <= pixel_row) and (pixel_row <= hp_position + text_two_window_size)
    ) else '0';


-------------------------------------------------------------------------------------------------------------------------
process(vert_sync)
begin
     if (rising_edge(vert_sync)) then
         score_hundreds_address <= CONV_STD_LOGIC_VECTOR(48, 6) + hundreds_score_in;
         score_tens_address <= CONV_STD_LOGIC_VECTOR(48, 6) + tens_score_in;
         score_ones_address <= CONV_STD_LOGIC_VECTOR(48, 6) + ones_score_in;
     end if;
	  hp_bar_right_end <= health_points + CONV_STD_LOGIC_VECTOR(95, 10);
end process;

bar_on <= '1' when ((CONV_STD_LOGIC_VECTOR(96, 10) <= pixel_column) and (pixel_column <= hp_bar_right_end) and 
    (hp_position + (CONV_STD_LOGIC_VECTOR(4,10)) <= pixel_row) and (pixel_row  <= hp_position + text_two_window_size)
    ) else '0';


-----------------------------------------------------------------------------------------------------------------------
--SET CURRENT CHARACTER_ATTRIBUTES AT CURERNT PIXEL_ROW/PIXEL_COLUMN
-----------------------------------------------------------------------------------------------------------------------
DISPLAY_UI: process(flappy_f, flappy_l, flappy_a, flappy_p1, flappy_p2, flappy_y, flappy_position,
bird_b, bird_i, bird_r, bird_d, bird_position,
play_p, play_l, play_a, play_y, play_position,
train_t, train_r, train_a, train_i, train_n, train_position,
arrow_up, arrow_down, arrow_position,
gameover_a, gameover_m, gameover_e1, gameover_o, gameover_v, gameover_e2, gameover_r,
paused_p, paused_a, paused_u, paused_s, paused_e, paused_d,
score_s, score_c, score_o, score_r, score_e, score_colon,
score_hundreds, score_tens, score_ones, score_position, score_ones_address, score_tens_address, score_hundreds_address,
hp_h, hp_p, hp_colon, hp_position,
menu_on, game_on, paused_on, gameover_on,    
alphabet_char_addr_list, text_two_window_size, char_two_spacing_position, text_two_char_size,
text_one_window_size, char_one_spacing_position, text_one_char_size)
    variable v_hp_on : std_logic;
begin
    if (rising_edge(clk)) then
        case state is
            -- MENU
            when "000" =>
            v_hp_on := '0';
            if (flappy_f = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(5);
                current_char_pos_x <= flappy_position;
                current_char_pos_y <= flappy_position;    
            elsif (flappy_l = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(11);
                current_char_pos_x <= flappy_position + char_two_spacing_position(1);
                current_char_pos_y <= flappy_position;
            elsif (flappy_a = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(0);
                current_char_pos_x <= flappy_position + char_two_spacing_position(2);
                current_char_pos_y <= flappy_position;
            elsif (flappy_p1 = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(15);
                current_char_pos_x <= flappy_position + char_two_spacing_position(3);
                current_char_pos_y <= flappy_position;
            elsif (flappy_p2 = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(15);
                current_char_pos_x <= flappy_position + char_two_spacing_position(4);
                current_char_pos_y <= flappy_position;    
            elsif (flappy_y = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(24);
                current_char_pos_x <= flappy_position + char_two_spacing_position(5);
                current_char_pos_y <= flappy_position;
                ------------------------------------------------
        -- bird
        ------------------------------------------------
            elsif (bird_b = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(1);
                current_char_pos_x <= bird_position;
                current_char_pos_y <= flappy_position;    
            elsif (bird_i = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(8);
                current_char_pos_x <= bird_position + char_two_spacing_position(1);
                current_char_pos_y <= flappy_position;
            elsif (bird_r = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(17);
                current_char_pos_x <= bird_position + char_two_spacing_position(2);
                current_char_pos_y <= flappy_position;
            elsif (bird_d = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(3);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(448,10);
                current_char_pos_y <= flappy_position; 
            elsif (train_t = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(19);
                current_char_pos_x <= train_position - CONV_STD_LOGIC_VECTOR(1,10);   
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(272, 10);
            elsif (train_r = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(17);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(271, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(272, 10);                      
            elsif (train_a = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(0);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(287, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(272, 10);  
            elsif (train_i = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(8);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(303, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(272, 10);
            elsif (train_n = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(13);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(319, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(272, 10);
            elsif (play_p = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(15);
                current_char_pos_x <= play_position;   
                current_char_pos_y <= play_position;
            elsif (play_l = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(11);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(271, 10);
                current_char_pos_y <= play_position;                      
            elsif (play_a = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(0);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(287, 10);
                current_char_pos_y <= play_position;  
            elsif (play_y= '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(24);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(303, 10);
                current_char_pos_y <= play_position;
            elsif (arrow_up = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= "011111";
                current_char_pos_x <= arrow_position;
                current_char_pos_y <= play_position;  
            elsif (arrow_down = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= "011111";
                current_char_pos_x <= arrow_position;
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(272, 10);
            elsif (sw0_s = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(18);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(47,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(352, 10);
            elsif (sw0_w = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(22);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(63,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(352, 10);
            elsif (sw0_0 = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= CONV_STD_LOGIC_VECTOR(48, 6);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(79,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(352, 10);
            elsif (uparrow = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= CONV_STD_LOGIC_VECTOR(30,6);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(63,10); 
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(337, 10);
            elsif (downarrow = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= CONV_STD_LOGIC_VECTOR(28, 6);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(63,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(368, 10);
            elsif (key0_k = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(10);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(111,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(352, 10);
            elsif (key0_e = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(4);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(127,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(352, 10);
            elsif (key0_y = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= CONV_STD_LOGIC_VECTOR(25, 6);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(143,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(352, 10);
            elsif (key0_0 = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= CONV_STD_LOGIC_VECTOR(48, 6);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(159,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(352, 10);
            elsif (select_arrow= '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= CONV_STD_LOGIC_VECTOR(31, 6);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(175,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(352, 10);
            else
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(2); -- display C
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(640,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(480,10);
            end if;
            -- GAME OVER
            when "011" =>
            v_hp_on := '0';
            if (gameover_g = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(6);
                current_char_pos_x <= gameover_position;
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10);
            elsif (gameover_a = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(0);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(192, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10);
            elsif (gameover_m = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(12);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(224, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10); 
            elsif (gameover_e1 = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(4);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(256, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10);
            elsif (gameover_o = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(14);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(320, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10);
            elsif (gameover_v = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(21);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(352, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10);
            elsif (gameover_e2 = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(4);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(384, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10);
            elsif (gameover_r = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(17);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(416, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10);
            elsif (menu_m = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(12);
                current_char_pos_x <= train_position - CONV_STD_LOGIC_VECTOR(1,10);   
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(272, 10);
            elsif (menu_e = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(4);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(271, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(272, 10);                      
            elsif (menu_n = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(13);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(287, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(272, 10);  
            elsif (menu_u = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(20);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(303, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(272, 10);
            elsif (retry_r1 = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(17);
                current_char_pos_x <= play_position;   
                current_char_pos_y <= play_position;
            elsif (retry_e = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(4);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(271, 10);
                current_char_pos_y <= play_position;                      
            elsif (retry_t = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(19);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(287, 10);
                current_char_pos_y <= play_position;  
            elsif (retry_r2 = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(17);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(303, 10);
                current_char_pos_y <= play_position;
            elsif (retry_y = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= alphabet_char_addr_list(24);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(319, 10);
                current_char_pos_y <= play_position;
            elsif (arrow_up = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= "011111";
                current_char_pos_x <= arrow_position;
                current_char_pos_y <= play_position;  
            elsif (arrow_down = '1') then
                current_char_size <= text_one_char_size;
                current_char_addr <= "011111";
                current_char_pos_x <= arrow_position;
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(272, 10);
            else
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(6); -- display G
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(640,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(480,10);
            end if;
            -- PAUSED
            when "100" =>
            v_hp_on := '0';
            if (paused_p = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(15);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(224, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10);
            elsif (paused_a = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(0);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(256, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10);
            elsif (paused_u = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(20);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(288, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10); 
            elsif (paused_s = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(18);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(320, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10);
            elsif (paused_e = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(4);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(352, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10);
            elsif (paused_d = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(3);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(384, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(224, 10);
            else
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(7); -- display H
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(640,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(480,10);
            end if;
            -- PLAYING
            when others =>
            v_hp_on := '1';
                if (score_hundreds = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= score_hundreds_address;
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(544,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(0, 10);
            elsif (score_tens = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= score_tens_address;
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(576,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(0, 10);
            elsif (score_ones = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= score_ones_address;
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(608,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(0, 10); 
            elsif (score_s = '1') then
                -- current_char_size <= text_two_char_size;
                -- current_char_addr <= CONV_STD_LOGIC_VECTOR(45, 6); -- 45 for -
                -- current_char_pos_x <= CONV_STD_LOGIC_VECTOR(352,10);
                -- current_char_pos_y <= CONV_STD_LOGIC_VECTOR(0, 10);
            elsif (score_c = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(18); -- 2 for c 18 for s
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(384,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(0, 10);
            elsif (score_o = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(2); -- 2 for c 14 for o
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(416,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(0, 10); 
            elsif (score_r = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(17);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(448,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(0, 10);
            elsif (score_e = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= CONV_STD_LOGIC_VECTOR(5, 6);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(480,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(0, 10); 
            elsif (score_colon = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= CONV_STD_LOGIC_VECTOR(61, 6);
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(512,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(0, 10); 
            elsif (hp_h = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(7);
                current_char_pos_x <= hp_position;
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(0, 10);
            elsif (hp_p = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(15);
                current_char_pos_x <= hp_position + char_two_spacing_position(1);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(0, 10);
            elsif (hp_colon = '1') then
                current_char_size <= text_two_char_size;
                current_char_addr <= CONV_STD_LOGIC_VECTOR(61, 6);
                current_char_pos_x <= hp_position + CONV_STD_LOGIC_VECTOR(64, 10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(0, 10);
            else
                current_char_size <= text_two_char_size;
                current_char_addr <= alphabet_char_addr_list(4); -- display E
                current_char_pos_x <= CONV_STD_LOGIC_VECTOR(480,10);
                current_char_pos_y <= CONV_STD_LOGIC_VECTOR(1,10);
            end if;
        end case;

        char_size <= current_char_size;
        char_adr_out <= current_char_addr;
        char_position_x_out <= current_char_pos_x;
        char_position_y_out <= current_char_pos_y;

        if (v_hp_on = '1') then
            hp_bar_rgb(11 downto 8) <= bar_on & bar_on & bar_on & bar_on;
            hp_bar_rgb(7 downto 4) <= "0000";
            hp_bar_rgb(3 downto 0) <= "0000";
        else
            hp_bar_rgb(11 downto 0) <= CONV_STD_LOGIC_VECTOR(0,12);
        end if;
    end if;
end process;
-------------------------------------------------------------------------------------------------------------------------
-- PASS CURRENT CHARACTER AT CURERNT PIXEL_ROW/PIXEL_COLUMN TO OUTPUT
-------------------------------------------------------------------------------------------------------------------------
-- char_size <= current_char_size;
-- char_adr_out <= current_char_addr;
-- char_position_x_out <= current_char_pos_x;
-- char_position_y_out <= current_char_pos_y;

-------------------------------------------------------------------------------------------------------------------------
-- PASS HP BAR ON TO RGB OUTPUT
-- hp_bar_rgb(11 downto 8) <= bar_on & bar_on & bar_on & bar_on;
-- hp_bar_rgb(7 downto 4) <= "0000";
-- hp_bar_rgb(3 downto 0) <= "0000";
-------------------------------------------------------------------------------------------------------------------------


END behavior;

