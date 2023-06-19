LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY state_machine IS
    PORT
        ( clk, vert_sync, reset   : IN std_logic;
			 deadCheck, SWITCH_GAME, PUSH_BUTTON       : IN std_logic;
			 gameReset : out std_logic;
			 state : OUT std_logic_vector(2 downto 0));
END state_machine;

architecture behavior of state_machine is
-------------------------------------------------------------------------------------------------------------------------
-- NO LONGER USING CUSTOM TYPE STATES
-------------------------------------------------------------------------------------------------------------------------
-- "000" = START
-- "001" = TRAIN
-- "010" = PLAY
-- "011" = DEAD
-- "100" = PAUSE

BEGIN 

-- ACTIVE LOW
stateCheck : process(clk)
variable prevButton : std_logic := '1';
variable prevState : std_logic_vector(2 downto 0) := "000";
variable currentState : std_logic_vector(2 downto 0) := "000";
variable varReset : std_logic := '0';
BEGIN
    if rising_edge(clk) then
			if reset = '1' then
				prevState := "000";
				currentState := "000";
			end if;
			varReset := '0';
			case currentState is
				-- START STATE
				when "000" =>
					
					-- GO TO TRAIN
					if SWITCH_GAME = '0' and PUSH_BUTTON = '0' and prevButton = '1'  then
						prevButton := '0';
						prevState := "000";
						currentState := "001";
					-- GO TO PLAY
					ELSIF SWITCH_GAME = '1' and PUSH_BUTTON = '0' and prevButton = '1' then
					   prevButton := '0';
						prevState := "000";
						currentState := "010";
					-- When held
					elsif PUSH_BUTTON = '0' and prevButton = '0' then
						prevButton := '0';
					-- No longer held
					else
						prevButton := '1';
					end if;
				-- TRAIN STATE
				when "001" =>
					if deadCheck = '1' then
						prevState := "001";
						currentState := "011";
					-- WHEN PRESSED, NOT HELD, PAUSE
					elsif PUSH_BUTTON = '0' and prevButton = '1' then
						prevButton := '0';
						prevState := "001";
						currentState := "100";
					-- CLICK HELD
					elsif PUSH_BUTTON = '0' and prevButton = '0' then
						prevButton := '0';
					ELSE
						prevButton := '1';
					end if;
				-- PLAY STATE
				when "010" =>
					if deadCheck = '1' then
						prevState := "010";
						currentState := "011";
					-- WHEN PRESSED, NOT HELD, PAUSE
					elsif PUSH_BUTTON = '0' and prevButton = '1' then
						prevButton := '0';
						prevState := "010";
						currentState := "100";
					-- CLICK HELD
					elsif PUSH_BUTTON = '0' and prevButton = '0' then
						prevButton := '0';
					ELSE
						prevButton := '1';
					end if;
				-- DEAD STATE
				when "011" =>
					if PUSH_BUTTON = '0' and prevButton = '1' then
						prevButton := '0';
						varReset := '1';
						-- TRY AGAIN
						if SWITCH_GAME = '1' then
							currentState := prevState;
						-- MAIN MENU
						else
							currentState := "000";
						end if;
					elsif PUSH_BUTTON = '0' then
						prevButton := '0';
					else 
						prevButton := '1';
					end if;
				-- PAUSE STATE
				when "100" =>
					
					-- WHEN PRESSED, NOT HELD, PAUSE
					if PUSH_BUTTON = '0' and prevButton = '1' then
						prevButton := '0';
						currentState := prevState;
					-- CLICK HELD, DONT ALLOW CONTINUE
					elsif PUSH_BUTTON = '0' and prevButton = '0' then
						prevButton := '0';
					ELSE
						prevButton := '1';
					end if;
				when others => currentState := "000";
				END CASE;
		end if;
		gameReset <= varReset;
		state <= currentState;
end process stateCheck;

end behavior;