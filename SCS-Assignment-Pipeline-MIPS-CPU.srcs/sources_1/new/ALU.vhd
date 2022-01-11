library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.MipsDefinitions.all;

entity ALU is
  Port (  a:            in std_logic_vector(31 downto 0);
          b:            in std_logic_vector(31 downto 0);
          AluOp:        in t_alu_op;
          sh_amount:    in natural;
          result:       out std_logic_vector(31 downto 0));
end ALU;

architecture Behavioral of ALU is

begin

ALU_COMPUTATIONS: process(a, b, sh_amount, AluOp) 
variable rot_amount         : natural := 0;
variable result_unsigned    : unsigned(31 downto 0) := (others => '0');
variable a_unsigned         : unsigned(31 downto 0);
variable b_unsigned         : unsigned(31 downto 0);
variable result_signed      : signed(31 downto 0) := (others => '0');
variable a_signed           : signed(31 downto 0);
variable b_signed           : signed(31 downto 0);
begin

    a_unsigned := unsigned(a);
    b_unsigned := unsigned(b);
    a_signed := signed(a);
    b_signed := signed(b);
    rot_amount := to_integer(unsigned(b));
    
    case AluOp is
        when op_OR => 
            result <= a or b;
            
        when op_AND => 
            result <= a and b;
            
        when op_NAND => 
            result <= a nand b;
            
        when op_SLL => 
            result_unsigned := shift_left(b_unsigned, sh_amount);
            result <= std_logic_vector(result_unsigned);    
            
        when op_SRL => 
            result_unsigned := shift_right(b_unsigned, sh_amount);
            result <= std_logic_vector(result_unsigned);
            
        when op_ROL =>    
            result_signed := rotate_left(a_signed, rot_amount);
            result <= std_logic_vector(result_signed);
            
        when op_ROR => 
            result_signed := rotate_right(a_signed, rot_amount);
            result <= std_logic_vector(result_signed);    
            
        when op_ADD =>
            result_signed := a_signed + b_signed;
            result <= std_logic_vector(result_signed);
             
        when op_SUB => 
             result_signed := a_signed - b_signed;
             result <= std_logic_vector(result_signed);

        when op_SLT => 
            result(31 downto 0) <= (others => '0');
            if a < b then 
                result(0) <= '1';
            end if;      
            
        when op_PASS_B => 
            result <= b;    
            
        when op_PASS_A => 
            result <= a;
            
    end case;
end process; 

end Behavioral;