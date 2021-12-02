library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Comparator is
  Port ( 
      a:        in std_logic_vector(31 downto 0);
      b:        in std_logic_vector(31 downto 0);
      less:     out std_logic;
      equal:    out std_logic;
      greater:  out std_logic
  );
end Comparator;

architecture Behavioral of Comparator is

begin

process(a,b)
variable a_signed : signed(31 downto 0);
variable b_signed : signed(31 downto 0);
begin
    a_signed := signed(a);
    b_signed := signed(b);
    less <= '0';
    equal <= '0';
    greater <= '0';
    if a_signed < b_signed then
        less <= '1';
    elsif a_signed = b_signed then
        equal <= '1';
    else
        greater <= '1';
    end if;            
end process;
end Behavioral;
