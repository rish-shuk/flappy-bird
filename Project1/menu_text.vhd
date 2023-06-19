LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY menu_text IS
	PORT
		(
		    clk, vert_sync                       : in std_logic;
		    pixel_row, pixel_column 			 : in std_logic_vector(9 downto 0);
            char_adr_out                         : out std_logic_vector(5 downto 0);
            char_size                           : out std_logic_vector(2 downto 0);
            char_position_x_out, char_position_y_out	: out std_logic_vector(9 downto 0)
          );		
END menu_text;

architecture behavior of menu_text is
    type alphabet_char_address is array (0 to 25) of std_logic_vector(5 downto 0);
    type char_spacing is array (0 to 79) of std_logic_vector(9 downto 0);

    SIGNAL current_char_addr                      : std_logic_vector(5 downto 0);
    SIGNAL current_char_pos_x, current_char_pos_y : std_logic_vector(9 downto 0);
    SIGNAL current_char_size                      : std_logic_vector(2 downto 0);
    
    SIGNAL alphabet_char_addr_list : alphabet_char_address := ("000001", "000010", "000011", 
    "000100", "000101", "000110", "000111", "001000", "001001", "001010", "001011", "001100",
     "001101", "001110", "001111", "010000", "010001", "010010", "010011", "010100", "010101", 
     "010110", "010111", "011000", "011001", "011010");
    
    SIGNAL char_spacing_position : char_spacing;

    SIGNAL window_size                                 : std_logic_vector(9 downto 0);
    SIGNAL flappy_position                             : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(128, 10);
    signal flappy_f, flappy_l, flappy_a, flappy_p1, 
    flappy_p2, flappy_y                                : std_logic := '0';
    SIGNAL bird_position                               : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(384, 10);
    signal bird_b, bird_i, bird_r, bird_d              : std_logic := '0';
    signal score_position                              : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(256, 10);
    signal score_hundreds, score_tens, score_ones      : std_logic := '0';
    signal score_counter                               : integer;
    signal score_address                               : std_logic_vector(5 downto 0);
    signal lives_position                              : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0,10);
    signal lives_one, lives_two, lives_three           : std_logic := '0';
    signal flappybird_on                               : std_logic := '1';
    signal game_on                                    : std_logic := '1';
    signal paused_on                                  : std_logic := '1';
    signal gameover_on                                : std_logic := '1';
BEGIN           

--char_adr_in: address of the character you want to display (address table is in OCT but must send 6 bit binary) use CONV_STD_LOGIC_VECTOR(integer converted from oct, 6);
--char_size: character size, can only double its previous size (ranges from 0-7);
--char_position_x or y; char position in the screen starting from its top left pixel in the mif file.

current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);

window_size <= CONV_STD_LOGIC_VECTOR(8, 10) when current_char_size = "000" else
    CONV_STD_LOGIC_VECTOR(16, 10) when current_char_size = "001" else
    CONV_STD_LOGIC_VECTOR(32, 10) when current_char_size = "010" else
    CONV_STD_LOGIC_VECTOR(64, 10) when current_char_size = "011" else
    CONV_STD_LOGIC_VECTOR(128, 10) when current_char_size = "100" else
    CONV_STD_LOGIC_VECTOR(256, 10) when current_char_size = "101" else
    CONV_STD_LOGIC_VECTOR(512, 10) when current_char_size = "110" else
    CONV_STD_LOGIC_VECTOR(1024, 10);

CHARSPACING: process(window_size, char_spacing_position)
begin
    for i in 0 to 20 loop
        char_spacing_position(i) <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(window_size * CONV_STD_LOGIC_VECTOR(i, 10)), 10);
    end loop;
end process;

-- -- character_on when pixel_* is at specified position
flappy_f <= '1' when (
    (flappy_position <= pixel_column) and (pixel_column <= flappy_position + window_size) and 
    (flappy_position <= pixel_row) and (pixel_row  <= flappy_position + window_size)
    ) else '0';

flappy_l <= '1' when (
    (flappy_position + window_size <= pixel_column) and (pixel_column <= flappy_position + window_size * CONV_STD_LOGIC_VECTOR(2,10)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + window_size)
    ) else '0';

flappy_a <= '1' when (
    (flappy_position + window_size * CONV_STD_LOGIC_VECTOR(2,10) <= pixel_column) and (pixel_column <= flappy_position + window_size * CONV_STD_LOGIC_VECTOR(3,10)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + window_size)
    ) else '0';

flappy_p1 <= '1' when (
    (flappy_position + window_size * CONV_STD_LOGIC_VECTOR(3,10) <= pixel_column) and (pixel_column <= flappy_position + window_size * CONV_STD_LOGIC_VECTOR(4,10)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + window_size)
    ) else '0';

flappy_p2 <= '1' when (
    (flappy_position + window_size * CONV_STD_LOGIC_VECTOR(4,10) <= pixel_column) and (pixel_column <= flappy_position + window_size * CONV_STD_LOGIC_VECTOR(5,10)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + window_size)
    ) else '0';

flappy_y <= '1' when (
    (flappy_position + window_size * CONV_STD_LOGIC_VECTOR(5,10) <= pixel_column) and (pixel_column <= flappy_position + window_size * CONV_STD_LOGIC_VECTOR(6,10)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + window_size)
    ) else '0';

--------------------------------------------------------------------------------------------------------------------

bird_b <= '1' when (
    (bird_position <= pixel_column) and (pixel_column <= bird_position + window_size) and 
    (flappy_position <= pixel_row) and (pixel_row  <= flappy_position + window_size)
    ) else '0';

bird_i <= '1' when (
    (bird_position + window_size <= pixel_column) and (pixel_column <= bird_position + window_size * CONV_STD_LOGIC_VECTOR(2,10)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + window_size)
    ) else '0';

bird_r <= '1' when (
    (bird_position + window_size * CONV_STD_LOGIC_VECTOR(2,10) <= pixel_column) and (pixel_column <= bird_position + window_size * CONV_STD_LOGIC_VECTOR(3,10)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + window_size)
    ) else '0';

bird_d <= '1' when (
    (bird_position + window_size * CONV_STD_LOGIC_VECTOR(3,10) <= pixel_column) and (pixel_column <= bird_position + window_size * CONV_STD_LOGIC_VECTOR(4,10)) and 
    (flappy_position <= pixel_row) and (pixel_row <= flappy_position + window_size)
    ) else '0';

----------------------------------------------------------------------------------------------------------------------



-- -- when character_on = '1', set current_char_* to specified character.
score_hundreds <= '1' when (
    (score_position <= pixel_column) and (pixel_column <= score_position + window_size) and 
    (score_position <= pixel_row) and (pixel_row  <= score_position + window_size)
    ) else '0';

score_tens <= '1' when (
    (score_position + window_size <= pixel_column) and (pixel_column <= score_position + window_size * CONV_STD_LOGIC_VECTOR(2,10)) and 
    (score_position <= pixel_row) and (pixel_row <= score_position + window_size)
    ) else '0';

score_ones <= '1' when (
    (score_position + window_size * CONV_STD_LOGIC_VECTOR(2,10) <= pixel_column) and (pixel_column <= score_position + window_size * CONV_STD_LOGIC_VECTOR(3,10)) and 
    (score_position <= pixel_row) and (pixel_row <= score_position + window_size)
    ) else '0';

-----------------------------------------------------------------------------------------------------------------------
lives_one <= '1' when (
    (lives_position <= pixel_column) and (pixel_column <= lives_position + window_size) and 
    (lives_position <= pixel_row) and (pixel_row  <= lives_position + window_size)
    ) else '0';

lives_two <= '1' when (
    (lives_position + window_size <= pixel_column) and (pixel_column <= lives_position + window_size * CONV_STD_LOGIC_VECTOR(2,10)) and 
    (lives_position <= pixel_row) and (pixel_row <= lives_position + window_size)
    ) else '0';

lives_three <= '1' when (
    (lives_position + window_size * CONV_STD_LOGIC_VECTOR(2,10) <= pixel_column) and (pixel_column <= lives_position + window_size * CONV_STD_LOGIC_VECTOR(3,10)) and 
    (lives_position <= pixel_row) and (pixel_row <= lives_position + window_size)
    ) else '0';

--------------------------------------------------------------------------------------------------------------------
process(vert_sync)
    variable character_select  : integer;
    variable counter           : integer := 0;
    variable test_speed_count  : integer := 0;
begin
    if (rising_edge(vert_sync)) then
        if (test_speed_count = 25) then
            if (counter = 15) then
                counter := 0;
            else 
                counter := counter + 1;
            end if;
            test_speed_count := 0;
        else
            test_speed_count := test_speed_count + 1;
        end if;
    character_select := 48 + counter;
    score_address <= CONV_STD_LOGIC_VECTOR((character_select),6);
    end if;
end process;



FLAPPY: process(flappy_f, flappy_l, flappy_a, flappy_p1, flappy_p2, flappy_y, flappy_position,
bird_b, bird_i, bird_r, bird_d, bird_position,
score_hundreds, score_tens, score_ones, score_position, score_address,
lives_one, lives_two, lives_three, lives_position,
alphabet_char_addr_list, window_size, char_spacing_position)
begin
    if (flappybird_on = '1') then
        if (flappy_f = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= alphabet_char_addr_list(5);
            current_char_pos_x <= flappy_position;
            current_char_pos_y <= flappy_position;    
        elsif (flappy_l = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= "111111";--alphabet_char_addr_list(11);
            current_char_pos_x <= flappy_position + char_spacing_position(1);
            current_char_pos_y <= flappy_position;
        elsif (flappy_a = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= alphabet_char_addr_list(0);
            current_char_pos_x <= flappy_position + char_spacing_position(2);
            current_char_pos_y <= flappy_position;
        elsif (flappy_p1 = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= alphabet_char_addr_list(15);
            current_char_pos_x <= flappy_position + char_spacing_position(3);
            current_char_pos_y <= flappy_position;
        elsif (flappy_p2 = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= alphabet_char_addr_list(15);
            current_char_pos_x <= flappy_position + char_spacing_position(4);
            current_char_pos_y <= flappy_position;    
        elsif (flappy_y = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= alphabet_char_addr_list(24);
            current_char_pos_x <= flappy_position + char_spacing_position(5);
            current_char_pos_y <= flappy_position;
    ------------------------------------------------
        elsif (bird_b = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= alphabet_char_addr_list(1);
            current_char_pos_x <= bird_position;
            current_char_pos_y <= flappy_position;    
        elsif (bird_i = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= alphabet_char_addr_list(8);
            current_char_pos_x <= bird_position + char_spacing_position(1);
            current_char_pos_y <= flappy_position;
        elsif (bird_r = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= alphabet_char_addr_list(17);
            current_char_pos_x <= bird_position + char_spacing_position(2);
            current_char_pos_y <= flappy_position;
        elsif (bird_d = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= alphabet_char_addr_list(3);
            current_char_pos_x <= bird_position + CONV_STD_LOGIC_VECTOR(96,10);
            current_char_pos_y <= flappy_position; 
        else
             --current_char_size <= CONV_STD_LOGIC_VECTOR(1, 3);
            current_char_addr <= "101110"; -- display .
            current_char_pos_x <= CONV_STD_LOGIC_VECTOR(640,10);
            current_char_pos_y <= CONV_STD_LOGIC_VECTOR(480,10);
        end if;
    elsif (game_on = '1') then
        if (score_hundreds = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= score_address;
            current_char_pos_x <= score_position;
            current_char_pos_y <= score_position;
        elsif (score_tens = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= score_address;
            current_char_pos_x <= score_position + char_spacing_position(1);
            current_char_pos_y <= score_position;
        elsif (score_ones = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= score_address;
            current_char_pos_x <= score_position + CONV_STD_LOGIC_VECTOR(64, 10);
            current_char_pos_y <= score_position; 
        elsif (lives_one = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= "111111";
            current_char_pos_x <= lives_position;
            current_char_pos_y <= lives_position;
        elsif (lives_two = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= "111111";
            current_char_pos_x <= lives_position + char_spacing_position(1);
            current_char_pos_y <= lives_position;
        elsif (lives_three = '1') then
            --current_char_size <= CONV_STD_LOGIC_VECTOR(2, 3);
            current_char_addr <= "111111";
            current_char_pos_x <= lives_position + CONV_STD_LOGIC_VECTOR(64, 10);
            current_char_pos_y <= lives_position;
        else
            --current_char_size <= CONV_STD_LOGIC_VECTOR(1, 3);
            current_char_addr <= "101110"; -- display .
            current_char_pos_x <= CONV_STD_LOGIC_VECTOR(640,10);
            current_char_pos_y <= CONV_STD_LOGIC_VECTOR(480,10);
        end if;
    elsif (gameover_on = '1') then

    elsif (paused_on ='1') then


    else
        --current_char_size <= CONV_STD_LOGIC_VECTOR(1, 3);
        current_char_addr <= "101110"; -- display .
        current_char_pos_x <= CONV_STD_LOGIC_VECTOR(640,10);
        current_char_pos_y <= CONV_STD_LOGIC_VECTOR(480,10);
    end if;

end process;

char_size <= current_char_size;
char_adr_out <= current_char_addr;
char_position_x_out <= current_char_pos_x;
char_position_y_out <= current_char_pos_y;
END behavior;

