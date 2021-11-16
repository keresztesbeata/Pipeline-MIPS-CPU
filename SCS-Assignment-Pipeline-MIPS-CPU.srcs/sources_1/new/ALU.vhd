library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MipsDefinitions.all;

entity ALU is
  Port (  a:            in std_logic_vector(31 downto 0);
          b:            in std_logic_vector(31 downto 0);
          AluOp:        in t_alu_op;
          sh_amount:    in integer;
          result:       out std_logic_vector(31 downto 0));
end ALU;

architecture Behavioral of ALU is

begin

ALU_COMPUTATIONS: process(a, b, sh_amount, AluOp) 
variable rot_amount : integer := 0;
begin
rot_amount := conv_integer(b);
    case AluOp is
        when op_OR => 
            result <= a or b;
            
        when op_AND => 
            result <= a and b;
            
        when op_NAND => 
            result <= a nand b;
            
        when op_SLL => 
            if (sh_amount > 0) then
                result(31 downto sh_amount) <= b(31-sh_amount downto 0);
                if(sh_amount = 1) then
                    result(0) <= '0';
                else
                    result(sh_amount-1 downto 0) <= (others => '0'); 
                end if;    
            end if;     
            
        when op_SRL => 
            if (sh_amount > 0) then
                result(31-sh_amount downto 0) <= b(31 downto sh_amount);
                if (sh_amount = 1) then
                    result(31) <= '0';
                else
                    result(31 downto 31-sh_amount+1) <= (others => '0');
                end if;    
            end if;     
            
        when op_ROR => 
            -- rotate right by the nr of bits specified in the immediate ( = rot_amount)
            if (rot_amount > 0) then
                result(31-rot_amount downto 0) <= a(31 downto rot_amount);
                result(31 downto 31-rot_amount+1) <= a(rot_amount-1 downto 0);
            end if;    
            
        when op_ROL =>
            -- rotate left by the nr of bits specified in the immediate ( = rot_amount)     
            if (rot_amount > 0) then
                result(31 downto rot_amount) <= a(31-rot_amount downto 0);
                result(rot_amount-1 downto 0) <= a(31 downto 31-rot_amount+1);  
            end if;
            
        when op_ADD => 
            result <= a + b;
            
        when op_SUB => 
            result <= a - b;
            
        when op_SLT => 
            result(31 downto 0) <= (others => '0');
            if a < b then 
                result(0) <= '1';
            end if;      
            
        when op_PASS_B => 
            result <= b;    
            
        when others => -- PASS A
            result <= a;
            
    end case;
end process; 

end Behavioral;