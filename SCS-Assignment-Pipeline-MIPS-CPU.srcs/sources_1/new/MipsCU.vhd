----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2021 08:47:38 PM
-- Design Name: 
-- Module Name: MipsCU - Behavioral
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

entity MipsCU is
  Port ( opcode: in std_logic_vector(31 downto 0);
         funct: in std_logic_vector(5 downto 0);
         RegDest: out std_logic;
         AluSrc: out std_logic;
         ShiftVar: out std_logic_vector(1 downto 0);
         AluOp: out std_logic_vector(3 downto 0);
         ExtOp: out std_logic;
         MemWrite: out std_logic;
         LB: out std_logic;
         SB: out std_logic;
         MemToReg: out std_logic_vector(2 downto 0);
         RegWrite: out std_logic;
         LinkRetAddr: out std_logic;
         Bgt: out std_logic;
         Bezr: out std_logic;
         Bltzal: out std_logic;
         Jal: out std_logic;
         Jalr: out std_logic;
         Jr: out std_logic
         );
end MipsCU;

architecture Behavioral of MipsCU is

type t_instr is (i_NOP, i_NAND, i_SUB, i_LWR, i_SWR, i_SLLV, i_SRLV, i_MOV, i_BEZR, i_JR, i_JALR, i_ORI, i_ADDI, i_LB, i_SB, i_BGT, i_BLTZAL, i_LUI, i_ROL, i_ROR, i_LWPI, i_SWPI, i_SLTI, i_SWAPM, i_ADDM, i_JAL);
signal instr : t_instr := i_NOP;

type t_alu_op is (op_OR, op_AND, op_NAND, op_SLL, op_SRL, op_ROL, op_ROR, op_ADD, op_SUB, op_SLT, op_PASS_B, op_X);
signal alu_op: t_alu_op;

type t_instr_to_alu_map is array(t_instr'left to t_instr'right) of t_alu_op;
signal instr_to_alu_lut : t_instr_to_alu_map := (
    i_NOP => op_OR,
    i_NAND => op_NAND, 
    i_SUB => op_SUB,
    i_LWR => op_ADD,
    i_SWR => op_ADD,
    i_SLLV => op_SLL,
    i_SRLV => op_SRL,
    i_MOV => op_PASS_B,
    i_BEZR => op_X,
    i_JR => op_X,
    i_JALR => op_X,
    i_ORI => op_OR,
    i_ADDI => op_ADD,
    i_LB => op_ADD,
    i_SB => op_ADD,
    i_BGT => op_X,
    i_BLTZAL => op_X,
    i_LUI => op_SLL,
    i_ROL => op_ROL,
    i_ROR => op_ROR,
    i_LWPI => op_ADD,
    i_SWPI => op_ADD,
    i_SLTI => op_SLT,
    i_SWAPM => op_ADD,
    i_ADDM => op_ADD,
    i_JAL => op_X
); 

-- generate the index of the instruction in the enum using the opcode and funct bits 
function computeInstructionIndex(opcode: std_logic_vector(5 downto 0); funct: std_logic_vector(5 downto 0); nrRegTypeInstr: integer) return integer is
variable instrIdx :integer := 0;
begin
    if (opcode = 0) then 
        instrIdx := to_integer(unsigned(funct));
    else
        instrIdx := nrRegTypeInstr - 1 + to_integer(unsigned(opcode));    
    end if;
    return instrIdx;     
end computeInstructionIndex;

begin

CONTROL_LOGIC:process(instr)
variable instr: t_instr := i_NOP;
variable alu_op: t_alu_op := op_X;  
begin
    -- initialize all signals to 0, except AluOp, which is determined based on the opcode and funct bits
    RegDest <= '0';
    AluSrc <= '0';
    ShiftVar <= (others => '0');
    ExtOp <= '0';
    MemWrite <= '0';
    LB <= '0';
    SB <= '0';
    MemToReg <= (others => '0');
    RegWrite <= '0';
    LinkRetAddr <= '0';
    Bgt <= '0';
    Bezr <= '0';
    Bltzal <= '0';
    Jal <= '0';
    Jalr <= '0';
    Jr <= '0';
    
    ---- decode the opcode and the function bits to identify the instruction
    instr := t_instr'val(computeInstructionIndex(opcode, funct, 11));
    -- map the instr to the corresponding alu op
    alu_op := instr_to_alu_lut(instr);
    -- get the ALU_op specific for the given instruction based on the LUT defined above
    AluOp <= std_logic_vector(to_unsigned(t_alu_op'pos(alu_op), AluOp'length));
    
    -- map all the instructions to their corresponding control signals
    case instr is
        when i_NOP => RegDest <= '1'; RegWrite <= '1';
        when i_NAND => RegDest <= '1'; RegWrite <= '1';  
        when i_SUB => RegDest <= '1'; RegWrite <= '1'; 
        when i_LWR => RegDest <= '1'; RegWrite <= '1'; MemToReg <= "001";
        when i_SWR => MemWrite <= '1'; 
        when i_SLLV => RegDest <= '1'; RegWrite <= '1'; ShiftVar <= "01";
        when i_SRLV => RegDest <= '1'; RegWrite <= '1'; ShiftVar <= "01";
        when i_MOV => RegDest <= '1'; RegWrite <= '1'; AluSrc <= '1';
        when i_ADDI => AluSrc <= '1'; ExtOp <= '1'; RegWrite <= '1';
        when i_ORI => AluSrc <= '1'; RegWrite <= '1';
        when i_ROL => AluSrc <= '1'; RegWrite <= '1';
        when i_ROR => AluSrc <= '1'; RegWrite <= '1';
        when i_LUI => AluSrc <= '1'; ExtOp <= '1'; ShiftVar <= "10"; MemToReg <= "001"; RegWrite <= '1'; 
        when i_LB => AluSrc <= '1'; ExtOp <= '1'; LB <= '1';  MemToReg <= "001"; RegWrite <= '1'; 
        when i_SB => AluSrc <= '1'; SB <= '1'; MemWrite <= '1';
        when i_LWPI => AluSrc <= '1'; ExtOp <= '1'; MemToReg <= "100"; RegWrite <= '1';
        when i_SWPI => AluSrc <= '1'; ExtOp <= '1'; MemWrite <= '1'; MemToReg <= "010"; RegWrite <= '1';  
        when i_SLTI => AluSrc <= '1'; ExtOp <= '1'; RegWrite <= '1';
        when i_SWAPM => AluSrc <= '1'; ExtOp <= '1'; MemWrite <= '1'; MemToReg <= "001"; RegWrite <= '1';
        when i_ADDM => AluSrc <= '1'; ExtOp <= '1'; MemToReg <= "011"; RegWrite <= '1';
        when i_JR => Jr <= '1';
        when i_JAL => LinkRetAddr <= '1'; RegWrite <= '1'; Jal <= '1';
        when i_JALR => LinkRetAddr <= '1'; RegWrite <= '1'; Jalr <= '1';
        when i_BEZR => Bezr <= '1';
        when i_BLTZAL => LinkRetAddr <= '1'; RegWrite <= '1'; Bltzal <= '1';
        when i_BGT => Bgt <= '1';
    end case;
end process;


--IDENTIFY_INSTR: process(opcode, funct)
--begin
--    case opcode is
--        when "000000" => 
--            case funct is
--                when "000000" => instr <= i_NOP;
--                when "000001" => instr <= i_NAND;
--                when "000010" => instr <= i_SUB;
--                when "000011" => instr <= i_LWR;
--                when "000100" => instr <= i_SWR;
--                when "000101" => instr <= i_SLLV;
--                when "000110" => instr <= i_SRLV;
--                when "000111" => instr <= i_MOV;
--                when "001000" => instr <= i_BEZR;
--                when "001001" => instr <= i_JR;
--                when "001010" => instr <= i_JALR;
--                when others => instr <= i_NOP;
--            end case;    
--        when "000001" => instr <= i_ORI;
--        when "000010" => instr <= i_ADDI;
--        when "000011" => instr <= i_LB;
--        when "000100" => instr <= i_SB;
--        when "000101" => instr <= i_BGTZ;
--        when "000110" => instr <= i_BLTZAL;
--        when "000111" => instr <= i_LUI;
--        when "001000" => instr <= i_ROL;
--        when "001001" => instr <= i_ROR;
--        when "001010" => instr <= i_LWPI;
--        when "001011" => instr <= i_SWPI;
--        when "001100" => instr <= i_SLTI;
--        when "001101" => instr <= i_SWAPM;
--        when "001110" => instr <= i_ADDM;
--        when "001111" => instr <= i_JAL;
--        when others => instr <= i_NOP;
--    end case;
--end process;

end Behavioral;
