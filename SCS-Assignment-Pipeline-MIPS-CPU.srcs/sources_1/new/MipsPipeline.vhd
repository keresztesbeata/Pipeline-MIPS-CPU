library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MipsDefinitions.all;

entity MipsPipeline is
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
--  led: out std_logic_vector(15 downto 0)
  );
end MipsPipeline;

architecture Behavioral of MipsPipeline is

component InstructionFetch is
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
end component;

component InstructionDecode is
 Port (
      clk:               in std_logic;
      rst:               in std_logic;
      Flush:             in std_logic;
      RegWrite:          in std_logic; -- comes from WB pipeline stage
      pc:                in std_logic_vector(31 downto 0);
      instruction:       in std_logic_vector(31 downto 0);
      write_addr:        in std_logic_vector(4 downto 0);
      write_data:        in std_logic_vector(31 downto 0);
      branch_address:    out std_logic_vector(31 downto 0);
      jump_address:      out std_logic_vector(31 downto 0);
      register_address:  out std_logic_vector(31 downto 0);
      PCSrc:             out std_logic;
      id_if_control:     out t_if_control_signals;
      id_ex_pc:          out std_logic_vector(31 downto 0); 
      id_ex_A:           out std_logic_vector(31 downto 0);
      id_ex_B:           out std_logic_vector(31 downto 0);
      id_ex_imm:         out std_logic_vector(31 downto 0);
      id_ex_sa:          out std_logic_vector(4 downto 0);
      id_ex_rt:          out std_logic_vector(4 downto 0);
      id_ex_rd:          out std_logic_vector(4 downto 0);
      id_ex_control:     out t_ex_control_signals;
      id_mem_control:    out t_mem_control_signals;
      id_wb_control:     out t_wb_control_signals  
   );
end component;      

component Execute is
 Port ( 
      clk:                  in std_logic;
      Flush:                in std_logic;
      ex_control:           in t_ex_control_signals;
      mem_control:          in t_mem_control_signals;
      wb_control:           in t_wb_control_signals;
      pc:                   in std_logic_vector(31 downto 0);
      A:                    in std_logic_vector(31 downto 0);
      B:                    in std_logic_vector(31 downto 0);
      imm:                  in std_logic_vector(31 downto 0);
      sa:                   in std_logic_vector(4 downto 0);
      rt:                   in std_logic_vector(4 downto 0);
      rd:                   in std_logic_vector(4 downto 0); 
      ex_mem_pc:            out std_logic_vector(31 downto 0);
      ex_mem_AluResult:     out std_logic_vector(31 downto 0);
      ex_mem_B:             out std_logic_vector(31 downto 0);
      ex_mem_RegWriteAddr:  out std_logic_vector(4 downto 0);
      ex_mem_control:       out t_mem_control_signals;
      ex_wb_control:        out t_wb_control_signals
  );
end component;

component Memory is
  Port ( 
      clk:                in std_logic;
      rst:                in std_logic;
      Flush:              in std_logic;
      mem_control:        in t_mem_control_signals;
      wb_control:         in t_wb_control_signals;
      pc:                 in std_logic_vector(31 downto 0);
      AluResult:          in std_logic_vector(31 downto 0);
      B:                  in std_logic_vector(31 downto 0);
      RegWriteAddr:       in std_logic_vector(4 downto 0);
      mem_wb_pc:          out std_logic_vector(31 downto 0);
      mem_wb_MemData:     out std_logic_vector(31 downto 0);
      mem_wb_AluResult:   out std_logic_vector(31 downto 0);
      mem_wb_Binc:        out std_logic_vector(31 downto 0);
      mem_wb_MemDataInc:  out std_logic_vector(31 downto 0);
      mem_wb_MemDataAdded:out std_logic_vector(31 downto 0);
      mem_wb_RegWriteAddr:out std_logic_vector(4 downto 0);
      mem_wb_control:     out t_wb_control_signals
      );
end component;      
  
component WriteBack is
    Port ( 
      wb_control:         in t_wb_control_signals;
      pc:                 in std_logic_vector(31 downto 0);
      AluResult:          in std_logic_vector(31 downto 0);
      Binc:               in std_logic_vector(31 downto 0);
      MemData:            in std_logic_vector(31 downto 0);
      MemDataInc:         in std_logic_vector(31 downto 0);
      MemDataAdded:       in std_logic_vector(31 downto 0);
      RegWriteAddr:       in std_logic_vector(4 downto 0);
      RegWriteData:       out std_logic_vector(31 downto 0)
      );
end component;        
  
signal rst: std_logic;
-- control signals
signal if_control: t_if_control_signals;
signal id_ex_control: t_ex_control_signals;
signal id_mem_control, ex_mem_control: t_mem_control_signals;
signal id_wb_control, ex_wb_control, mem_wb_control: t_wb_control_signals;

signal branch_address, jump_address, reg_address:         std_logic_vector(31 downto 0);
signal if_id_pc, id_ex_pc, ex_mem_pc, mem_wb_pc:          std_logic_vector(31 downto 0);
signal instruction:                                       std_logic_vector(31 downto 0);
signal PCSrc:                                             std_logic;
signal Flush:                                             std_logic := '0';
signal A, B, imm:                                         std_logic_vector(31 downto 0);
signal sa:                                                std_logic_vector(4 downto 0);
signal rt, rd:                                            std_logic_vector(4 downto 0);
signal AluResult, mem_wb_AluResult:                       std_logic_vector(31 downto 0);
signal MemWriteData:                                      std_logic_vector(31 downto 0);  
signal ex_mem_RegWriteAddr:                               std_logic_vector(4 downto 0);
signal MemData:                                           std_logic_vector(31 downto 0);
signal Binc:                                              std_logic_vector(31 downto 0);
signal MemDataInc:                                        std_logic_vector(31 downto 0);
signal MemDataAdded:                                      std_logic_vector(31 downto 0);
signal mem_wb_RegWriteAddr:                               std_logic_vector(4 downto 0);
signal RegWriteData:                                      std_logic_vector(31 downto 0);

begin

rst <= btnU;

IF_STAGE: InstructionFetch port map (
    clk => clk,
    rst => rst,
    Flush => Flush,
    if_control => if_control,
    PCSrc => PCSrc,
    branch_address => branch_address,
    jump_address => jump_address,
    register_address => reg_address,
    if_id_pc => if_id_pc,
    if_id_instruction => instruction
);

ID_STAGE: InstructionDecode port map (
      clk => clk,
      rst => rst,
      Flush => Flush,
      RegWrite => mem_wb_control.RegWrite,
      pc => if_id_pc,
      instruction => instruction,
      write_addr => mem_wb_RegWriteAddr,
      write_data => RegWriteData,
      branch_address => branch_address,
      jump_address => jump_address,
      register_address => reg_address,
      PCSrc => PCSrc,
      id_if_control => if_control,
      id_ex_pc => id_ex_pc, 
      id_ex_A => A,
      id_ex_B => B,
      id_ex_imm => imm,
      id_ex_sa => sa,
      id_ex_rt => rt,
      id_ex_rd => rd,
      id_ex_control => id_ex_control,
      id_mem_control => id_mem_control,
      id_wb_control => id_wb_control
      );
      
EX_STAGE: Execute port map(
      clk => clk,
      Flush => Flush,
      ex_control => id_ex_control,
      mem_control => id_mem_control,
      wb_control => id_wb_control,
      pc => id_ex_pc,
      A => A,
      B => B,
      imm => imm,
      sa => sa,
      rt => rt,
      rd => rd, 
      ex_mem_pc => ex_mem_pc,
      ex_mem_AluResult => AluResult,
      ex_mem_B => MemWriteData,
      ex_mem_RegWriteAddr => ex_mem_RegWriteAddr,
      ex_mem_control => ex_mem_control,
      ex_wb_control => ex_wb_control
);   

MEM_STAGE: Memory port map( 
      clk => clk,
      rst => rst,
      Flush => Flush,
      mem_control => ex_mem_control,
      wb_control => ex_wb_control,
      pc => ex_mem_pc,
      AluResult => AluResult,
      B => MemWriteData,
      RegWriteAddr => ex_mem_RegWriteAddr,
      mem_wb_pc => mem_wb_pc,
      mem_wb_MemData => MemData,
      mem_wb_AluResult => mem_wb_AluResult,
      mem_wb_Binc => Binc,
      mem_wb_MemDataInc => MemDataInc,
      mem_wb_MemDataAdded => MemDataAdded,
      mem_wb_RegWriteAddr => mem_wb_RegWriteAddr,
      mem_wb_control => mem_wb_control
);
    
WB_STAGE: WriteBack port map(
      wb_control => mem_wb_control,
      pc => mem_wb_pc,
      AluResult => mem_wb_AluResult,
      Binc => Binc,
      MemData => MemData,
      MemDataInc => MemDataInc,
      MemDataAdded => MemDataAdded,
      RegWriteAddr => mem_wb_RegWriteAddr,
      RegWriteData => RegWriteData
);    

debug_pc <= if_id_pc;
debug_branch_addr <= branch_address;
debug_jump_addr <= jump_address;
debug_reg_addr <= reg_address;
debug_A <= A;
debug_B <= B;
debug_immm <= imm;
debug_AluResult <= AluResult;
debug_MemWriteData <= MemWriteData;
debug_MemData <= MemData;
debug_MemDataInc <= MemDataInc;
debug_MemDataAdded <= MemDataAdded;
debug_RegWriteAddr <= mem_wb_RegWriteAddr;
debug_RegWriteData <= RegWriteData; 

--led(0) <= id_ex_control.AluSrc;
--led(1) <= id_wb_control.RegWrite;
--led(3 downto 2) <= id_ex_control.RegDest;
--led(6 downto 4) <= id_wb_control.MemToReg;
--led(7) <= id_wb_control.LinkRetAddr;
--led(15 downto 8) <= (others => '0');       

end Behavioral;
