library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MipsDefinitions.all;

entity InstructionFetch is
  Port (
      clk:              in std_logic;
      rst:              in std_logic;
      PCWrite:          in std_logic;
      BranchSel:        in std_logic;
      JumpSel:          in std_logic;
      PCSrc:            in std_logic;
      Jump:             in std_logic;
      branch_address:   in std_logic_vector(31 downto 0);
      jump_address:     in std_logic_vector(31 downto 0);
      register_address: in std_logic_vector(31 downto 0);
      pc_out:           out std_logic_vector(31 downto 0);
      instruction:      out std_logic_vector(31 downto 0) 
  );
end InstructionFetch;

architecture Behavioral of InstructionFetch is

signal pc:                                              std_logic_vector(31 downto 0) := (others => '0');
signal pc_in, selected_jump_addr, selected_branch_addr: std_logic_vector(31 downto 0);
signal instr_mem :                                      t_instr_mem_array := c_mips_instruction_set;

begin

selected_jump_addr <= register_address when JumpSel = '1' else jump_address;
selected_branch_addr <= register_address when BranchSel = '1' else branch_address;
                        
pc_in <= selected_jump_addr when Jump = '1' 
         else selected_branch_addr when PCSrc = '1'
         else pc + 1;                        

program_counter: process(clk, rst)
begin
    if rst = '1' then
        pc <= (others => '0');
    elsif rising_edge(clk) then
        if PCWrite = '1' then
            pc <= pc_in; 
        end if;
    end if;
    pc_out <= pc;     
end process;

end Behavioral;
