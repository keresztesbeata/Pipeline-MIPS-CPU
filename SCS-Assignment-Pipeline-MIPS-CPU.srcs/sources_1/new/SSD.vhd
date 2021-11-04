----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/03/2021 01:22:21 PM
-- Design Name: 
-- Module Name: SSD - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SSD is
    Port (clk: in std_logic;
            rst: in std_logic;
            data: in std_logic_vector(15 downto 0);
            an: out std_logic_vector(3 downto 0);
            cat: out std_logic_vector(6 downto 0));
end SSD;

architecture Behavioral of SSD is

signal hex_digit : std_logic_vector(3 downto 0) := (others => '0');
signal sel : std_logic_vector(1 downto 0) := (others => '0');
signal counts : std_logic_vector(15 downto 0) := (others => '0');

begin


COUNTER: process(clk)
begin
    if(rising_edge(clk)) then
        counts <= counts + 1;
    end if;
end process;

sel <= counts(15 downto 14); 

MUX: process(sel, data, data)
begin
    case sel is
        when "00" => hex_digit <= data(3 downto 0); an <="1110";
        when "01" => hex_digit <= data(7 downto 4); an <="1101";
        when "10" => hex_digit <= data(11 downto 8); an <= "1011";
        when others => hex_digit <= data(15 downto 12); an <= "0111";
    end case;
end process;

with hex_digit select
   cat<= "1111001" when "0001",   --1
         "0100100" when "0010",   --2
         "0110000" when "0011",   --3
         "0011001" when "0100",   --4
         "0010010" when "0101",   --5
         "0000010" when "0110",   --6
         "1111000" when "0111",   --7
         "0000000" when "1000",   --8
         "0010000" when "1001",   --9
         "0001000" when "1010",   --A
         "0000011" when "1011",   --b
         "1000110" when "1100",   --C
         "0100001" when "1101",   --d
         "0000110" when "1110",   --E
         "0001110" when "1111",   --F
         "1000000" when others;   --0

end Behavioral;
