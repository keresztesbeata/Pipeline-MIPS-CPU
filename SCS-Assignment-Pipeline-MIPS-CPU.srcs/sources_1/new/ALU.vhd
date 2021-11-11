----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/05/2021 07:44:36 AM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
  Port (  a: in std_logic_vector(31 downto 0);
          b: in std_logic_vector(31 downto 0);
          AluOp: in std_logic_vector(3 downto 0);
          sa: in std_logic_vector(4 downto 0);
          result: out std_logic_vector(31 downto 0));
end ALU;

architecture Behavioral of ALU is

begin

ALU_COMPUTATIONS: process(a, b, sa, AluOp) 
variable sh_amount : integer := 0;
variable rot_amount : integer := 0;
begin
sh_amount := to_integer(unsigned(sa));
rot_amount := to_integer(unsigned(b));
    case AluOp is
        when "0000" => -- OR
            result <= a or b;
            
        when "0001" => -- AND
            result <= a and b;
            
        when "0010" => -- NAND
            result <= a nand b;
            
        when "0011" => -- SLL
            if (sh_amount > 0) then
                result(31 downto sh_amount) <= b(31-sh_amount downto 0);
                if(sh_amount = 1) then
                    result(0) <= '0';
                else
                    result(sh_amount-1 downto 0) <= (others => '0'); 
                end if;    
            end if;     
            
        when "0100" => -- SRL
            if (sh_amount > 0) then
                result(31-sh_amount downto 0) <= b(31 downto sh_amount);
                if (sh_amount = 1) then
                    result(31) <= '0';
                else
                    result(31 downto 31-sh_amount+1) <= (others => '0');
                end if;    
            end if;     
            
        when "0101" => -- ROL 
            -- rotate left by the nr of bits specified in the immediate ( = rot_amount)
            if (rot_amount > 0) then
                result(31-rot_amount downto 0) <= a(31 downto rot_amount);
                 if (rot_amount = 1) then
                    result(31) <= a(0);
                else    
                    result(31 downto 31-rot_amount+1) <= a(rot_amount-1 downto 0);
                end if;  
            end if;    
            
        when "0110" => -- ROR
            -- rotate right by the nr of bits specified in the immediate ( = rot_amount)     
            if (rot_amount > 0) then
                result(31 downto rot_amount) <= a(31-rot_amount downto 0);
                if (rot_amount = 1) then
                    result(0) <= a(31);
                else 
                    result(rot_amount-1 downto 0) <= a(31 downto 31-rot_amount+1);     
                end if;            
            end if;
            
        when "0111" => -- ADD
            result <= a + b;
            
        when "1000" => -- SUB
            result <= a - b;
            
        when "1001" => -- SLT
            result(31 downto 0) <= (others => '0');
            if a < b then 
                result(0) <= '1';
            end if;      
            
        when "1010" => -- PASS B
            result <= b;    
            
        when others => -- PASS A
            result <= a;
            
    end case;
end process; 

end Behavioral;
