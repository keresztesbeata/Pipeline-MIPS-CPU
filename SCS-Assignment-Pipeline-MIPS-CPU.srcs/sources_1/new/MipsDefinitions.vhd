library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package MipsDefinitions is

constant c_instr_mem_size: natural := 30;
constant c_reg_file_size: natural := 30;
constant c_data_mem_size: natural := 30;

type t_instr_mem_array is array(0 to c_instr_mem_size-1) of std_logic_vector(31 downto 0);
type t_reg_file_array is array(0 to c_reg_file_size-1) of std_logic_vector(31 downto 0);

constant c_mips_instruction_set: t_instr_mem_array := (
B"000000_00000_00000_00000_00000_000000", --Nop	
B"000000_00001_00010_00011_00000_000001", --Nand
B"000000_00001_00010_00011_00000_000010", --Sub
B"000000_00001_00010_00011_00000_000011", --Lwr
B"000000_00001_00010_00011_00000_000100", --Swr
B"000000_00001_00010_00011_00000_000101", --Sllv
B"000000_00001_00010_00011_00000_000110", --Srlv
B"000000_00001_00010_00011_00000_000111", --Mov
B"000000_00001_00010_00000_00000_001000", --Bezr
B"000000_00001_00000_00000_00000_001001", --Jr
B"000000_00001_00000_00000_00000_001010", --Jalr
B"000001_00001_00010_0000_0000_0000_0000", --Ori
B"000010_00001_00010_0000_0000_0000_0000", --Addi
B"000011_00001_00010_0000_0000_0000_0000", --Lb
B"000100_00001_00010_0000_0000_0000_0000", --Sb
B"000101_00001_00010_0000_0000_0000_0011", --Bgt
B"000110_00001_00010_0000_0000_0000_0011", --Bltzal
B"000111_00000_00010_0000_0010_0000_0011", --Lui
B"001000_00001_00010_0000_0000_0000_0011", --Rol
B"001001_00001_00010_0000_0000_0000_0011", --Ror
B"001010_00001_00010_0000_0000_0000_0011", --Lwpi
B"001011_00001_00010_0000_0000_0000_0011", --Swpi
B"001100_00001_00010_0000_0000_0000_0011", --Slti
B"001101_00001_00010_0000_0000_0000_0011", --Swapm
B"001110_00001_00010_0000_0000_0000_0011", --Addm
B"001111_00_0000_0000_0000_0000_0000_0011", --Jal
others => (others => '0')
);

constant c_reg_file_init_data: t_reg_file_array := (
X"0000_0000",
X"0000_0001",
X"0000_0002",
X"0000_0003",
X"0000_0004",
X"0000_0005",
X"0000_0006",
X"0000_0007",
X"0000_0008",
X"0000_0009",
X"0000_000A",
X"0000_000B",
X"0000_000C",
X"0000_000D",
X"0000_000E",
X"0000_000F",
others => (others => '0')
);

type t_instr is (i_NOP, i_NAND, i_SUB, i_LWR, i_SWR, i_SLLV, i_SRLV, i_MOV, i_BEZR, i_JR, i_JALR, i_ORI, i_ADDI, i_LB, i_SB, i_BGT, i_BLTZAL, i_LUI, i_ROL, i_ROR, i_LWPI, i_SWPI, i_SLTI, i_SWAPM, i_ADDM, i_JAL);

type t_alu_op is (op_OR, op_AND, op_NAND, op_SLL, op_SRL, op_ROL, op_ROR, op_ADD, op_SUB, op_SLT, op_PASS_B, op_X);

type t_instr_to_alu_map is array(t_instr'left to t_instr'right) of t_alu_op;

type t_if_control_signals is record
     Bezr:          std_logic;
     Bltzal:        std_logic;
     Bgt:           std_logic;
     Jal:           std_logic;
     Jalr:          std_logic;
     Jr:            std_logic;
end record t_if_control_signals;

type t_id_control_signals is record
     ExtOp:      std_logic;
end record t_id_control_signals;

type t_ex_control_signals is record
      RegDest:      std_logic_vector(1 downto 0);
	  AluSrc:		std_logic;
	  AluOp:		t_alu_op;
	  ShiftVar:		std_logic_vector(1 downto 0);
end record t_ex_control_signals;

type t_mem_control_signals is record
      MemRead:      std_logic;
      MemWrite:     std_logic;
	  SB:			std_logic;
	  LB:			std_logic;
end record t_mem_control_signals;

type t_wb_control_signals is record
      RegWrite:     std_logic;
	  MemToReg:     std_logic_vector(2 downto 0);
	  LinkRetAddr:  std_logic;
end record t_wb_control_signals;

type t_data_mem_array is array(0 to c_data_mem_size-1) of std_logic_vector(31 downto 0);

constant c_data_mem_init_data: t_data_mem_array := (
X"0000_0000",
X"0001_0001",
X"0002_0002",
X"0003_0003",
X"0004_0004",
X"0005_0005",
X"0006_0006",
X"0007_0007",
X"0008_0008",
X"0009_0009",
X"000A_000A",
X"000B_000B",
X"000C_000C",
X"000D_000D",
X"000E_000E",
X"000F_000F",
others => (others => '0')
);

end MipsDefinitions;


