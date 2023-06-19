library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity random_idx is
    port (
        clk     : in std_logic;
        reset   : in std_logic;
        seed    : in std_logic_vector(15 downto 0);
        polynom : in std_logic_vector(15 downto 0);
        random_num  : out std_logic_vector(15 downto 0)
    );
end entity random_idx;

architecture rtl of random_idx is
    signal lfsr_reg : std_logic_vector(15 downto 0);
begin
  process (clk, reset)
  begin
    if (reset = '1') then
        lfsr_reg <= seed;
    elsif (rising_edge(clk)) then
      if (lfsr_reg(0) = '1') then
        lfsr_reg <= ('0' & lfsr_reg(15 downto 1)) xor polynom;
      else
          lfsr_reg <= '0' & lfsr_reg(15 downto 1);
      end if;
    end if;
  end process;
  
  random_num <= lfsr_reg;
end architecture;