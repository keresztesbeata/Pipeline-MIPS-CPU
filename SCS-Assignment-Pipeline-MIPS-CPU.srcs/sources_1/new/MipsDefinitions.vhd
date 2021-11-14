library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package MipsDefinitions is

constant c_instr_mem_size: natural := 30;

type t_instr_mem_array is array(0 to c_instr_mem_size-1) of std_logic_vector(31 downto 0);

constant c_mips_instruction_set: t_instr_mem_array := (
B"000000_00000_00000_00000_00000_000000", --Nop	
B"000000_00001_00010_00011_00000_000001", --Nand
B"000000_00001_00010_00011_00000_000010", --Sub
B"000001_00001_00010_0000_0000_0000_0000", --Ori
B"000010_00001_00010_0000_0000_0000_0000", --Addi
others => (others => '0')
);

type t_control_signals is record
     Flush:         std_logic;
     PCWrite:       std_logic;
     BranchSel:     std_logic;
     JumpSel:       std_logic;
     PCSrc:         std_logic;
     Jump:          std_logic;
end record t_control_signals;

constant c_control_signals_init: t_control_signals := 
(
     Flush => '0',
     PCWrite => '0',
     BranchSel => '0',
     JumpSel => '0',
     PCSrc => '0',
     Jump => '0'
);
end MipsDefinitions;


