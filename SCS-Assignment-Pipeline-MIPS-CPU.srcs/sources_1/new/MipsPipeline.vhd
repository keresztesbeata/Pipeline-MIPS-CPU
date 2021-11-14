library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MipsDefinitions.all;

entity MipsPipeline is
  Port (
  clk:  in std_logic;
  rst:  in std_logic
  );
end MipsPipeline;

architecture Behavioral of MipsPipeline is

component InstructionFetch is
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
end component;

signal control:                                           t_control_signals;
signal branch_address, jump_address, register_address:    std_logic_vector(31 downto 0);
signal pc:                                                std_logic_vector(31 downto 0);
signal instruction:                                       std_logic_vector(31 downto 0);

begin

IF_UNIT: InstructionFetch port map
(
    clk => clk,
    rst => rst,
    PCWrite => control.PCWrite,
    BranchSel => control.BranchSel,
    JumpSel => control.JumPSel,
    PCSrc => control.PCSrc,
    Jump => control.Jump,
    branch_address => branch_address,
    jump_address => jump_address,
    register_address => register_address,
    pc_out => pc,
    instruction => instruction
);
    
end Behavioral;
