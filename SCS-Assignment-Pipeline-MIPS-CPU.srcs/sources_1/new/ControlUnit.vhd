library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MipsDefinitions.all;

entity ControlUnit is
  Port ( 
      clk:               in std_logic;
      rst:               in std_logic;
      instruction:       in std_logic_vector(31 downto 0);
      if_control:        out t_if_control_signals;
      id_control:        out t_id_control_signals;
      ex_control:        out t_ex_control_signals;
      mem_control:       out t_mem_control_signals;
      wb_control:        out t_wb_control_signals  
      );    
end ControlUnit;

architecture Behavioral of ControlUnit is

signal instr_to_alu_lut : t_instr_to_alu_map := (
    i_NOP => op_OR,
    i_NAND => op_NAND, 
    i_SUB => op_SUB,
    i_LWR => op_ADD,
    i_LWRD => op_SUB,
    i_SLLV => op_SLL,
    i_SRLV => op_SRL,
    i_MOV => op_PASS_B,
    i_BEZR => op_PASS_A,
    i_JR => op_PASS_A,
    i_JALR => op_PASS_A,
    i_ORI => op_OR,
    i_ADDI => op_ADD,
    i_LB => op_ADD,
    i_SB => op_ADD,
    i_BGT => op_PASS_A,
    i_BLTZAL => op_PASS_A,
    i_LUI => op_SLL,
    i_ROL => op_ROL,
    i_ROR => op_ROR,
    i_LWPI => op_ADD,
    i_SWPI => op_ADD,
    i_SLTI => op_SLT,
    i_SWAPM => op_ADD,
    i_ADDM => op_ADD,
    i_JAL => op_PASS_A
); 

-- generate the index of the instruction in the enum using the opcode and funct bits 
function computeInstructionIndex(opcode: std_logic_vector(5 downto 0); funct: std_logic_vector(5 downto 0); nrRegTypeInstr: integer) return integer is
variable instrIdx :integer := 0;
begin 
    if (opcode = 0) then 
        instrIdx := conv_integer(funct);
    else
        instrIdx := nrRegTypeInstr - 1 + conv_integer(opcode);    
    end if;
    return instrIdx;     
end computeInstructionIndex;

begin

CONTROL_LOGIC: process(rst, instruction)
variable opcode, func:    std_logic_vector(5 downto 0);
variable instr: t_instr := i_NOP;
begin   
    opcode := instruction(31 downto 26);
    func := instruction(5 downto 0);
    ---- decode the opcode and the function bits to identify the instruction
    instr := t_instr'val(computeInstructionIndex(opcode, func, no_reg_type_instr));
    
    if_control <= (Bezr => '0', Bltzal => '0', Bgt => '0', Jal => '0', Jalr => '0', Jr => '0');
    id_control <= (ExtOp => '0');
    ex_control <= (RegDest => "00", AluSrc => '0', AluOp => op_PASS_A, ShiftVar => "00");
    mem_control <= (MemRead => '0', MemWrite => '0', SB => '0', LB => '0');
    wb_control <= (RegWrite => '0', LinkRetAddr => '0', MemToReg => "000");
  
    -- map the instr to the corresponding alu op
    ex_control.AluOp <= instr_to_alu_lut(instr);
    
    -- map all the instructions to their corresponding control signals
    case instr is
        when i_NOP => ex_control.RegDest <= "01"; wb_control.RegWrite <= '1';
        when i_NAND => ex_control.RegDest <= "01"; wb_control.RegWrite <= '1';
        when i_SUB => ex_control.RegDest <= "01"; wb_control.RegWrite <= '1'; 
        when i_LWR => ex_control.RegDest <= "01"; ex_control.AluSrc <='0'; mem_control.MemRead <= '1'; wb_control.RegWrite <= '1'; wb_control.MemToReg <= "001";
        when i_LWRD => ex_control.RegDest <= "01"; ex_control.AluSrc <='0'; mem_control.MemRead <= '1'; wb_control.RegWrite <= '1'; wb_control.MemToReg <= "001"; 
        when i_SLLV => ex_control.RegDest <= "01"; wb_control.RegWrite <= '1'; ex_control.ShiftVar <= "01";
        when i_SRLV => ex_control.RegDest <= "01"; wb_control.RegWrite <= '1'; ex_control.ShiftVar <= "01";
        when i_MOV =>  wb_control.RegWrite <= '1'; ex_control.RegDest <= "01";
        when i_ADDI => ex_control.AluSrc <= '1'; id_control.ExtOp <= '1'; wb_control.RegWrite <= '1';
        when i_ORI => ex_control.AluSrc <= '1'; wb_control.RegWrite <= '1';
        when i_ROL => ex_control.AluSrc <= '1'; id_control.ExtOp <= '1'; wb_control.RegWrite <= '1';
        when i_ROR => ex_control.AluSrc <= '1'; id_control.ExtOp <= '1'; wb_control.RegWrite <= '1';
        when i_LUI => ex_control.AluSrc <= '1'; id_control.ExtOp <= '1'; ex_control.ShiftVar <= "10"; wb_control.RegWrite <= '1'; 
        when i_LB => ex_control.AluSrc <= '1'; id_control.ExtOp <= '1'; mem_control.MemRead <= '1';  mem_control.LB <= '1';  wb_control.MemToReg <= "001"; wb_control.RegWrite <= '1'; 
        when i_SB => ex_control.AluSrc <= '1'; id_control.ExtOp <= '1'; mem_control.SB <= '1'; mem_control.MemWrite <= '1';
        when i_LWPI => ex_control.AluSrc <= '1'; id_control.ExtOp <= '1'; mem_control.MemRead <= '1'; wb_control.MemToReg <= "011"; wb_control.RegWrite <= '1';
        when i_SWPI => ex_control.AluSrc <= '1'; id_control.ExtOp <= '1'; mem_control.MemWrite <= '1'; wb_control.MemToReg <= "010"; wb_control.RegWrite <= '1';  
        when i_SLTI => ex_control.AluSrc <= '1'; id_control.ExtOp <= '1'; wb_control.RegWrite <= '1';
        when i_SWAPM => ex_control.AluSrc <= '1'; id_control.ExtOp <= '1'; mem_control.MemWrite <= '1'; mem_control.MemRead <= '1'; wb_control.MemToReg <= "001"; wb_control.RegWrite <= '1';
        when i_ADDM => ex_control.AluSrc <= '1'; id_control.ExtOp <= '1'; mem_control.MemRead <= '1'; wb_control.MemToReg <= "100"; wb_control.RegWrite <= '1';
        when i_JR => if_control.Jr <= '1'; 
        when i_JAL => wb_control.LinkRetAddr <= '1'; wb_control.RegWrite <= '1'; ex_control.RegDest <= "10"; if_control.Jal <= '1';
        when i_JALR => wb_control.LinkRetAddr <= '1'; wb_control.RegWrite <= '1'; ex_control.RegDest <= "10"; if_control.Jalr <= '1';
        when i_BEZR => if_control.Bezr <= '1';
        when i_BLTZAL => wb_control.LinkRetAddr <= '1'; wb_control.RegWrite <= '1'; ex_control.RegDest <= "10"; if_control.Bltzal <= '1';
        when i_BGT => if_control.Bgt <= '1';
    end case;
    
end process; 

end Behavioral;
