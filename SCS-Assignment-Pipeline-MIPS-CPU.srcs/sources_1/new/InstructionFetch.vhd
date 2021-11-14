library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MipsDefinitions.all;

entity InstructionFetch is
  Port (
      clk:               in std_logic;
      rst:               in std_logic;
      Flush:             in std_logic;
      if_control:        in t_if_control_signals;
      PCSrc:             in std_logic;
      branch_address:    in std_logic_vector(31 downto 0);
      jump_address:      in std_logic_vector(31 downto 0);
      register_address:  in std_logic_vector(31 downto 0);
      if_id_pc:          out std_logic_vector(31 downto 0);
      if_id_instruction: out std_logic_vector(31 downto 0) 
  );
end InstructionFetch;

architecture Behavioral of InstructionFetch is

signal pc:                                              std_logic_vector(31 downto 0) := (others => '0');
signal pc_in, selected_jump_addr, selected_branch_addr: std_logic_vector(31 downto 0);
signal instr_mem:                                       t_instr_mem_array := c_mips_instruction_set;
signal Jump, JumpSel, BranchSel:                        std_logic;

begin

Jump <= if_control.Jal or if_control.Jr or if_control.Jalr;
JumpSel <= if_control.Jalr or if_control.Jr; 
BranchSel <= if_control.Bezr;

selected_jump_addr <= register_address when JumpSel = '1' else jump_address;
selected_branch_addr <= register_address when BranchSel = '1' else branch_address;
                        
pc_in <= selected_jump_addr when Jump = '1' 
         else selected_branch_addr when PCSrc = '1'
         else pc + 1;                        

PROGRAM_COUNTER: process(clk, rst)
begin
    if rst = '1' then
        pc <= (others => '0');
    elsif rising_edge(clk) then
        if if_control.PCWrite = '1' then
            pc <= pc_in; 
        end if;
    end if; 
end process;

IF_ID_PIPE_REGISTER: process(clk, Flush)
begin
    if Flush = '1' then
        if_id_pc <= (others => '0');
        if_id_instruction <= (others => '0');
    elsif rising_edge(clk) then
        if_id_pc <= pc; 
        if_id_instruction <= instr_mem(conv_integer(pc));
    end if;   
end process;

end Behavioral;
