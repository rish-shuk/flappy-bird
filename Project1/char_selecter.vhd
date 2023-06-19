LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;
use ieee.numeric_std.all; 

ENTITY char_selector IS
	PORT
		(
            clk, vert_sync                                              : in std_logic;
            char_adr_in                                                 : in std_logic_vector(5 downto 0);
            char_size                                                   : in std_logic_vector(2 downto 0);
            char_position_x, char_position_y, pixel_row, pixel_column   : in std_logic_vector(9 downto 0);
		    character_address		                                    : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
            font_row, font_col                                          : OUT std_logic_vector(2 downto 0)
          );		
END char_selector;

architecture behavior of char_selector is
    signal char_active : std_logic;
    signal char_x, char_y : std_logic;
    signal pixel_column_position, pixel_row_position : std_logic_vector(2 downto 0);
    signal converted_char_position_x, converted_char_position_y : std_logic_vector(2 downto 0);
    signal window_size : std_logic_vector(9 downto 0);
BEGIN           
-- for text, character address represents which character is displayed
-- in char_rom/TCGROM, character address is in oct format to must change integer to oct

    -- SET TEXT POSITION
    -- to change size, change downto bit in pixel_*
    window_size <= CONV_STD_LOGIC_VECTOR(8, 10) when char_size = "000" else
        CONV_STD_LOGIC_VECTOR(16, 10) when char_size = "001" else
        CONV_STD_LOGIC_VECTOR(32, 10) when char_size = "010" else
        CONV_STD_LOGIC_VECTOR(64, 10) when char_size = "011" else
        CONV_STD_LOGIC_VECTOR(128, 10) when char_size = "100" else
        CONV_STD_LOGIC_VECTOR(256, 10) when char_size = "101" else
        CONV_STD_LOGIC_VECTOR(512, 10) when char_size = "110" else
        CONV_STD_LOGIC_VECTOR(1024, 10);


    pixel_column_position <= pixel_column(2 downto 0) when char_size = "000" else
        pixel_column(3 downto 1) when char_size = "001" else
        pixel_column(4 downto 2) when char_size = "010" else
        pixel_column(5 downto 3) when char_size = "011" else
        pixel_column(6 downto 4) when char_size = "100" else
        pixel_column(7 downto 5) when char_size = "101" else
        pixel_column(8 downto 6) when char_size = "110" else
        pixel_column(9 downto 7);

    pixel_row_position <= pixel_row(2 downto 0) when char_size = "000" else
        pixel_row(3 downto 1) when char_size = "001" else
        pixel_row(4 downto 2) when char_size = "010" else
        pixel_row(5 downto 3) when char_size = "011" else
        pixel_row(6 downto 4) when char_size = "100" else
        pixel_row(7 downto 5) when char_size = "101" else
        pixel_row(8 downto 6) when char_size = "110" else
        pixel_row(9 downto 7);

    
    char_x <= '1' when ((char_position_x <= pixel_column) and (pixel_column <= char_position_x + window_size)) else '0';
    char_y <= '1' when ((char_position_y <= pixel_row) and (pixel_row <= char_position_y + window_size)) else '0';

    char_active <= '1' when (char_x = '1' and char_y = '1') else '0';


    converted_char_position_x <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(char_position_x), 3);
    converted_char_position_y <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(char_position_y) - 1, 3);

    font_col <= (pixel_column_position + converted_char_position_x) when (char_active = '1') else "000";  
    font_row <= (pixel_row_position + converted_char_position_y) when (char_active = '1') else "000";  
    character_address <= char_adr_in;
    -- for displaying different text

    -- score_digit_tens_active <= '1' when (position_x and _position_y) else '0';
    -- font_* <= pixel_* when (char_active = '1' or score_digit_tens_active);



    
-- process(vert_sync)
--     variable character_select  : integer;
--     variable counter           : integer := 0;
--     variable test_speed_count  : integer := 0;
-- begin
--     if (rising_edge(vert_sync)) then
--         if (test_speed_count = 25) then
--             if (counter = 9) then
--                 counter := 0;
--             else 
--                 counter := counter + 1;
--             end if;
--             test_speed_count := 0;
--         else
--             test_speed_count := test_speed_count + 1;
--         end if;
--     character_select := 48 + counter;
--     character_address <= CONV_STD_LOGIC_VECTOR((character_select),6);
--     end if;
-- end process;
END behavior;

