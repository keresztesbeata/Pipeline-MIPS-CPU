library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package MipsDefinitions is

constant c_instr_mem_size: natural := 30;
constant c_reg_file_size: natural := 30;

type t_instr_mem_array is array(0 to c_instr_mem_size-1) of std_logic_vector(31 downto 0);
type t_reg_file_array is array(0 to c_reg_file_size-1) of std_logic_vector(31 downto 0);

constant c_mips_instruction_set: t_instr_mem_array := (
B"000000_00000_00000_00000_00000_000000", --Nop	
B"000000_00001_00010_00011_00000_000001", --Nand
B"000000_00001_00010_00011_00000_000010", --Sub
B"000001_00001_00010_0000_0000_0000_0000", --Ori
B"000010_00001_00010_0000_0000_0000_0000", --Addi
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
others => (others => '0')
);


type t_if_control_signals is record
     PCWrite:       std_logic;
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
end record t_ex_control_signals;

type t_mem_control_signals is record
      MemRead:      std_logic;
      MemWrite:     std_logic;
end record t_mem_control_signals;

type t_wb_control_signals is record
      RegWrite:     std_logic;
end record t_wb_control_signals;


end MipsDefinitions;


