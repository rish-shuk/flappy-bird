LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE  IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.ALL;

entity health is
    port(
        clk, vert_sync : in std_logic;
        reset, birdPerish : in std_logic;
        collision_signal_in : in std_logic;
        bonus1_collision_signal_in : in std_logic;
		    state : in std_logic_vector(2 downto 0);
		    deadCheck : out std_logic;
        health_points : out std_logic_vector(9 downto 0)
    );
end health;

architecture behavior of health is
begin

    process(clk, reset)
		  variable v_health : integer range 0 to 200 := 200;
		  variable isDead: std_logic := '0';
		  variable timer : integer range 0 to 150 := 100;
    begin
        if reset = '1' then
            v_health := 200;
				isDead := '0';
				timer := 100;
        elsif (rising_edge(clk)) then
		      if birdPerish = '1' or v_health = 0 then
					isDead := '1';
					v_health := 0;
            elsif collision_signal_in = '1' and state /= "100" then
					 timer := timer - 1;
					 if timer <= 0 then
						timer := 100;
						v_health := v_health - 1;
					 end if;
				--elsif bonus1_collision_signal_in = '1' then
					--v_health := 200;
            end if;
        end if;
		  deadCheck <= isDead;
		  health_points <= CONV_STD_LOGIC_VECTOR(v_health, 10);
    end process;
end architecture behavior;