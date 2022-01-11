library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package MipsDefinitions is

constant c_instr_mem_size: natural := 64;
constant c_reg_file_size: natural := 64;
constant c_data_mem_size: natural := 64;

type t_instr_mem_array is array(0 to c_instr_mem_size-1) of std_logic_vector(31 downto 0);
type t_reg_file_array is array(0 to c_reg_file_size-1) of std_logic_vector(31 downto 0);

constant c_mips_instruction_set: t_instr_mem_array := (
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00001_00010_00011_00000_000001", --Nand  	r[3] <- ! (r[1] & r[2])
B"000100_01010_01001_0000_0000_0000_0011", --Sb		M[r[10] + 3] <- r[9] & x000000FF
B"000000_00101_00100_00110_00000_000010", --Sub		r[6] <- r[5] - r[4]
B"000011_00111_01100_0000_0000_0000_0011", --Lb		r[12] <- M[r[7] + 3] & x000000FF
B"000000_00111_01000_01001_00000_000011", --Lwr		r[9] <- M[r[7] + r[8]]
B"000000_00010_00001_00100_00000_000100", --Lwrd	r[4] <-	M[r[2] - r[1]]
B"000000_00100_00101_00110_00000_000101", --Sllv	r[6] <- r[5] << r[4]
B"000000_00111_01110_01000_00000_000110", --Srlv	r[14] <- r[3] >> r[7]
B"000111_00000_01101_0000_0010_0000_0011", --Lui	r[13] <- x0203 << 16
B"000000_00000_01010_01011_00000_000111", --Mov		r[11] <- r[10]
B"001010_00101_00010_0000_0000_0000_0011", --Lwpi	r[2] <- M[r[5] + 3] + 1	
B"000001_00001_00100_0000_0000_0000_0011", --Ori	r[4] <- r[1] | 3
B"000010_00101_00110_0000_0000_0000_0011", --Addi	r[6] <- r[5] + 3
B"001011_00101_01101_0000_0000_0000_0011", --Swpi	M[r[5] + 3] <- r[13], r[13] <- r[13] + 1
B"001000_00101_00110_0000_0000_0001_1110", --Rol	r[6] <- r[5] rol 30
B"001001_01001_01101_0000_0000_0000_0010", --Ror	r[13] <- r[9] ror 2
B"001101_00101_01010_0000_0000_0000_0010", --Swapm  M[r[5] + 2] <-> r[10]
B"001100_00101_01011_0000_0000_0000_1010", --Slti	if r[5] < 10 then r[11] <- 1 else r[11] <- 0
B"001110_00001_00111_0000_0000_0000_0011", --Addm	r[7] <- r[7] + M[r[1] + 3]
B"000000_10000_10001_00000_00000_001000", --Bezr	if r[16] == 0 then PC <- PC + r[17] else PC <- PC + 1
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000101_01111_00001_0000_0000_0000_0100", --Bgt	if r[15] > r[1] then PC <- PC + 4 else PC <- PC + 1
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000110_00011_00000_0000_0000_0000_0011", --Bltzal if r[3] < 0 then r[31] <- PC + 1, PC <- PC + 3 else PC <- PC + 1
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_10010_00000_00000_00000_001001", --Jr		PC <- r[18]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_10011_00000_00000_00000_001010", --Jalr	r[31] <- PC + 1, PC <- r[19]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"000000_00000_00000_00000_00000_000000", --Nop	  	r[0] <- r[0] | r[0]
B"001111_00_0000_0000_0000_0000_0000_0001", --Jal	r[31] <- PC + 1, PC <- 1
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
X"0000_0119",
X"0000_000A",
X"0000_000B",
X"0000_000C",
X"0000_000D",
X"0000_000E",
X"0000_000F",
X"0000_0000",
X"0000_0004",
X"0000_0026",
X"0000_002A",
others => (others => '0')
);

type t_instr is (i_NOP, i_NAND, i_SUB, i_LWR, i_LWRD, i_SLLV, i_SRLV, i_MOV, i_BEZR, i_JR, i_JALR, i_ORI, i_ADDI, i_LB, i_SB, i_BGT, i_BLTZAL, i_LUI, i_ROL, i_ROR, i_LWPI, i_SWPI, i_SLTI, i_SWAPM, i_ADDM, i_JAL);

constant no_reg_type_instr: integer := 11;

type t_alu_op is (op_OR, op_AND, op_NAND, op_SLL, op_SRL, op_ROL, op_ROR, op_ADD, op_SUB, op_SLT, op_PASS_B, op_PASS_A);

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
X"0000_0010",
X"0000_0011",
X"0000_0012",
X"0000_0013",
X"0000_0014",
X"0000_0015",
X"0000_0016",
X"0000_0017",
X"0000_0018",
X"0000_0019",
X"0000_001A",
X"0000_001B",
X"0000_001C",
X"0000_001D",
X"0000_001E",
X"0000_001F",
others => (others => '0')
);

end MipsDefinitions;


