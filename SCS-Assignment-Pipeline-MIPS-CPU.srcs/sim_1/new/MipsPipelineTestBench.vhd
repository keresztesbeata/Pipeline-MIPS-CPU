library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.MipsDefinitions.all;

entity MipsPipelineTestBench is
--  Port ( );
end MipsPipelineTestBench;

architecture Behavioral of MipsPipelineTestBench is
component MipsPipeline is
  Port (
    clk:  in std_logic;
    btnU:  in std_logic;
    debug_pc: out std_logic_vector(31 downto 0);
    debug_branch_addr: out std_logic_vector(31 downto 0);
    debug_jump_addr: out std_logic_vector(31 downto 0);
    debug_reg_addr: out std_logic_vector(31 downto 0);
    debug_A: out std_logic_vector(31 downto 0);
    debug_B: out std_logic_vector(31 downto 0);
    debug_immm: out std_logic_vector(31 downto 0);
    debug_AluResult: out std_logic_vector(31 downto 0);
    debug_MemWriteData: out std_logic_vector(31 downto 0);
    debug_MemData: out std_logic_vector(31 downto 0);
    debug_MemDataInc: out std_logic_vector(31 downto 0);
    debug_MemDataAdded: out std_logic_vector(31 downto 0);
    debug_RegWriteAddr: out std_logic_vector(4 downto 0);
    debug_RegWriteData: out std_logic_vector(31 downto 0)
  );
end component;

signal clk:  std_logic;
signal btnU:  std_logic;
signal debug_pc: std_logic_vector(31 downto 0);
signal debug_branch_addr: std_logic_vector(31 downto 0);
signal debug_jump_addr: std_logic_vector(31 downto 0);
signal debug_reg_addr: std_logic_vector(31 downto 0);
signal debug_A: std_logic_vector(31 downto 0);
signal debug_B: std_logic_vector(31 downto 0);
signal debug_immm: std_logic_vector(31 downto 0);
signal debug_AluResult: std_logic_vector(31 downto 0);
signal debug_MemWriteData: std_logic_vector(31 downto 0);
signal debug_MemData: std_logic_vector(31 downto 0);
signal debug_MemDataInc: std_logic_vector(31 downto 0);
signal debug_MemDataAdded: std_logic_vector(31 downto 0);
signal debug_RegWriteAddr: std_logic_vector(4 downto 0);
signal debug_RegWriteData: std_logic_vector(31 downto 0);
    
begin

MIPS_UT: MipsPipeline port map(
    clk => clk,
    btnU => btnU,
    debug_pc => debug_pc,
    debug_branch_addr => debug_branch_addr,
    debug_jump_addr => debug_jump_addr,
    debug_reg_addr => debug_reg_addr,
    debug_A => debug_A,
    debug_B => debug_B,
    debug_immm => debug_immm,
    debug_AluResult => debug_AluResult,
    debug_MemWriteData => debug_MemWriteData, 
    debug_MemData => debug_MemData,
    debug_MemDataInc => debug_MemDataInc,
    debug_MemDataAdded => debug_MemDataAdded,
    debug_RegWriteAddr => debug_RegWriteAddr,
    debug_RegWriteData => debug_RegWriteData
); 

process
begin
    clk <= '0';
    wait for 100ns;
    clk <= '1';
    wait for 100ns;
end process;

process
begin
    btnU <= '1';
    wait for 200ns;
    btnU <= '0';
    wait;
end process;

end Behavioral;
