LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_MISC.all;
use ieee.numeric_std.all;


LIBRARY altera_mf;
USE altera_mf.all;

ENTITY sprite_rom IS
	PORT
	(
		bird_y_position         :   in std_logic_vector(9 downto 0);
		pixel_row, pixel_column	:	IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock, vert_sync				: 	IN STD_LOGIC ;
		rom_mux_output		:	OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END sprite_rom;


ARCHITECTURE SYN OF sprite_rom IS

	SIGNAL rom_data		: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL rom_address	: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL bird_on      : std_logic;
	SIGNAL current_pixel_counter : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
	SIGNAL previous_y_position   : STD_LOGIC_VECTOR(9 downto 0);
	COMPONENT altsyncram
	GENERIC (
		address_aclr_a			: STRING;
		clock_enable_input_a	: STRING;
		clock_enable_output_a	: STRING;
		init_file				: STRING;
		intended_device_family	: STRING;
		lpm_hint				: STRING;
		lpm_type				: STRING;
		numwords_a				: NATURAL;
		operation_mode			: STRING;
		outdata_aclr_a			: STRING;
		outdata_reg_a			: STRING;
		widthad_a				: NATURAL;
		width_a					: NATURAL;
		width_byteena_a			: NATURAL
	);
	PORT (
		clock0		: IN STD_LOGIC ;
		address_a	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		q_a			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
	END COMPONENT;

BEGIN

	altsyncram_component : altsyncram
	GENERIC MAP (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "bird_data_v4.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 342,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		widthad_a => 16	,
		width_a => 16,
		width_byteena_a => 2
	)
	PORT MAP (
		clock0 => clock,
		address_a => rom_address,
		q_a => rom_data
	);

	-- each line in memory corresponds to one pixel

	-- if bird is at pixel position (row,col) (240, 320);

	-- at position, rom_address <= 
	bird_on <= '1' when ((310 <= pixel_column) and (pixel_column <= 310 + CONV_STD_LOGIC_VECTOR(18,10)) and
					(bird_y_position - CONV_STD_LOGIC_VECTOR(9, 10) <= pixel_row) and (pixel_row <= bird_y_position + CONV_STD_LOGIC_VECTOR(17,10) 	- CONV_STD_LOGIC_VECTOR(9, 10) )) else '0';
	-- Since sprite is 19 (column) x 18 (row)
	--
	process(clock, pixel_column, pixel_row)
	begin
		if (bird_on = '1') then	
			if (rising_edge(clock)) then
				if (bird_y_position = previous_y_position) then
					if (current_pixel_counter = CONV_STD_LOGIC_VECTOR(342, 16)) then
						current_pixel_counter <= CONV_STD_LOGIC_VECTOR(1, 16);
					else
						current_pixel_counter <= current_pixel_counter +  CONV_STD_LOGIC_VECTOR(1, 16);
					end if;
				else
					current_pixel_counter <= CONV_STD_LOGIC_VECTOR(1, 16);
				end if;
				previous_y_position <= bird_y_position;
			end if;
			rom_address <= current_pixel_counter;
		else
			rom_address <= CONV_STD_LOGIC_VECTOR(1,16);
		end if;
	end process;

	rom_mux_output(11) <= rom_data(12);
	rom_mux_output(10) <= rom_data(13);
	rom_mux_output(9) <= rom_data(14);
	rom_mux_output(8) <= rom_data(15);
	rom_mux_output(7) <= rom_data(8);
	rom_mux_output(6) <= rom_data(9);
	rom_mux_output(5) <= rom_data(10);
	rom_mux_output(4) <= rom_data(11);
	rom_mux_output(3) <= rom_data(4);
	rom_mux_output(2) <= rom_data(5);
	rom_mux_output(1) <= rom_data(6);
	rom_mux_output(0) <= rom_data(7);
	-- process(rom_data)
	-- begin
	-- 	for i in 1 to 12 loop
	-- 		rom_mux_output(12-i) <= rom_data(i-1);
	-- 	end loop;
	-- end process; 	

END SYN; 