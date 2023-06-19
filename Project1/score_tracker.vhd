library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity score_tracker is
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
end score_tracker;

architecture behavior of score_tracker is

    constant PIPE_WIDTH : STD_LOGIC_VECTOR(10 downto 0) := CONV_STD_LOGIC_VECTOR(50, 11);
    signal prev_pipe1_x_pos : std_logic_vector(10 downto 0);
    signal prev_pipe2_x_pos : std_logic_vector(10 downto 0);
begin
    process (clk)
    variable ones_score :  std_logic_vector(3 downto 0) := CONV_STD_LOGIC_VECTOR(0, 4);
    variable tens_score :  std_logic_vector(3 downto 0) := CONV_STD_LOGIC_VECTOR(0, 4);
    variable hundreds_score :  std_logic_vector(3 downto 0) := CONV_STD_LOGIC_VECTOR(0, 4);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                ones_score := CONV_STD_LOGIC_VECTOR(0, 4);
                tens_score := CONV_STD_LOGIC_VECTOR(0, 4);
                hundreds_score := CONV_STD_LOGIC_VECTOR(0, 4);
            else
                if ((ball_x_pos < prev_pipe1_x_pos) and (ball_x_pos >= pipe1_x_pos)) or ((ball_x_pos < prev_pipe2_x_pos) and (ball_x_pos >= pipe2_x_pos)) then
                    ones_score := ones_score + CONV_STD_LOGIC_VECTOR(1, 4);
                    if ones_score > CONV_STD_LOGIC_VECTOR(9,4) then
                        tens_score := tens_score + CONV_STD_LOGIC_VECTOR(1, 4);
                        ones_score := CONV_STD_LOGIC_VECTOR(0, 4); 
                    elsif tens_score > CONV_STD_LOGIC_VECTOR(9,4) then
                        hundreds_score := hundreds_score + CONV_STD_LOGIC_VECTOR(1, 4);
                        tens_score := CONV_STD_LOGIC_VECTOR(0, 4);
                    end if;
                end if;
            end if;
            prev_pipe1_x_pos <= pipe1_x_pos;
            prev_pipe2_x_pos <= pipe2_x_pos;
        end if;
        ones_score_out <= ones_score;
        tens_score_out <= tens_score;
        hundreds_score_out <= hundreds_score;
    end process;
end behavior;