library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.MipsDefinitions.all;

entity MipsPipeline is
  Port (
    clk:        in std_logic;
    btnU:       in std_logic;
    btnD:       in std_logic;
    btnR:       in std_logic;
    sw:         in std_logic_vector(15 downto 0);
    an:         out std_logic_vector(3 downto 0);
    seg:        out std_logic_vector(6 downto 0);
    led:        out std_logic_vector(15 downto 0)
  );
end MipsPipeline;

architecture Behavioral of MipsPipeline is

component InstructionFetch is
 Port (
      clk:               in std_logic;
      PCWrite:           in std_logic;
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

component Debouncer is
  Port (clk:    in std_logic;
        rst:    in std_logic;
        d_in:   in std_logic;
        q_out:  out std_logic);
end component;        

component SSD is
    Port (
    clk:    in std_logic;
    rst:    in std_logic;
    data:   in std_logic_vector(15 downto 0);
    an:     out std_logic_vector(3 downto 0);
    cat:    out std_logic_vector(6 downto 0));
end component;           
  
signal rst:                                               std_logic;
signal en_pc:                                             std_logic;
signal Flush:                                             std_logic;
-- control signals
signal if_control:                                        t_if_control_signals;
signal id_ex_control:                                     t_ex_control_signals;
signal id_mem_control, ex_mem_control:                    t_mem_control_signals;
signal id_wb_control, ex_wb_control, mem_wb_control:      t_wb_control_signals;

signal branch_address, jump_address, reg_address:         std_logic_vector(31 downto 0);
signal if_id_pc, id_ex_pc, ex_mem_pc, mem_wb_pc:          std_logic_vector(31 downto 0);
signal instruction:                                       std_logic_vector(31 downto 0);
signal PCSrc:                                             std_logic;
signal A, B, imm:                                         std_logic_vector(31 downto 0);
signal sa:                                                std_logic_vector(4 downto 0);
signal rt, rd:                                            std_logic_vector(4 downto 0);
signal rs_ext, rt_ext:                                    std_logic_vector(31 downto 0);
signal AluResult, mem_wb_AluResult:                       std_logic_vector(31 downto 0);
signal MemWriteData:                                      std_logic_vector(31 downto 0);  
signal ex_mem_RegWriteAddr:                               std_logic_vector(4 downto 0);
signal MemData:                                           std_logic_vector(31 downto 0);
signal Binc:                                              std_logic_vector(31 downto 0);
signal MemDataInc:                                        std_logic_vector(31 downto 0);
signal MemDataAdded:                                      std_logic_vector(31 downto 0);
signal mem_wb_RegWriteAddr:                               std_logic_vector(4 downto 0);
signal RegWriteAddr_ext:                                  std_logic_vector(31 downto 0);
signal RegWriteData:                                      std_logic_vector(31 downto 0);

-- user interface signals
signal displayed_data:                                    std_logic_vector(31 downto 0);
signal select_displayed_data:                             integer;
signal select_control_signals:                            integer;

begin

rst <= btnU;

BTN_INC_STEP_DEBOUNCER: Debouncer port map(
    clk => clk, 
    rst => rst, 
    d_in => btnR, 
    q_out => en_pc);


BTN_FLUSH_PIPELINE_DEBOUNCER: Debouncer port map(
    clk => clk, 
    rst => rst, 
    d_in => btnD, 
    q_out => Flush);
    
IF_STAGE: InstructionFetch port map (
    clk => clk,
    PCWRite => en_pc,
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

select_control_signals <= to_integer(unsigned(sw(1 downto 0)));

process(select_control_signals, if_control, id_ex_control, ex_mem_control, mem_wb_control)
begin
    case select_control_signals is
        when 0 => 
            -- IF stage control signals
            led(0) <= if_control.Bezr;
            led(1) <= if_control.Bltzal;
            led(2) <= if_control.Bgt;
            led(3) <= if_control.Jal;
            led(4) <= if_control.Jalr;
            led(5) <= if_control.Jr;
            led(15 downto 6) <= (others => '0');
        when 1 =>
            -- EX stage control signals
            led(1 downto 0) <=id_ex_control.RegDest;
            led(2) <= id_ex_control.AluSrc;
            led(6 downto 3) <= std_logic_vector(to_unsigned(t_alu_op'pos(id_ex_control.AluOp), 4)); -- alu op
            led(8 downto 7) <= id_ex_control.ShiftVar;
            led(15 downto 9) <= (others => '0');
        when 2 =>
            -- MEM stage control signals
            led(0) <= ex_mem_control.MemRead;
            led(1) <= ex_mem_control.MemWrite;
            led(2) <= ex_mem_control.SB;
            led(3) <= ex_mem_control.LB;
            led(15 downto 4) <= (others => '0');
        when others =>
            -- WB stage control signals
            led(0) <= mem_wb_control.RegWrite;
            led(3 downto 1) <= mem_wb_control.MemToReg;
            led(4) <= mem_wb_control.LinkRetAddr;
            led(15 downto 5) <= (others => '0');
    end case; 
end process;

-- extend the register addresses to display them on the SSD

rs_ext(4 downto 0) <= instruction(25 downto 21);
rs_ext(31 downto 5) <= (others => '0');

rt_ext(4 downto 0) <= rt;
rt_ext(31 downto 5) <= (others => '0');

RegWriteAddr_ext(4 downto 0) <= mem_wb_RegWriteAddr;
RegWriteAddr_ext(31 downto 0) <= (others => '0');

select_displayed_data <= to_integer(unsigned(sw(15 downto 2)));

displayed_data <= if_id_pc          when select_displayed_data = 0 else
                  branch_address    when select_displayed_data = 1 else
                  jump_address      when select_displayed_data = 2 else
                  reg_address       when select_displayed_data = 3 else
                  rs_ext            when select_displayed_data = 4 else
                  rt_ext            when select_displayed_data = 5 else
                  A                 when select_displayed_data = 6 else
                  B                 when select_displayed_data = 7 else
                  imm               when select_displayed_data = 8 else
                  AluResult         when select_displayed_data = 9 else
                  MemWriteData      when select_displayed_data = 10 else
                  MemData           when select_displayed_data = 11 else
                  MemDataInc        when select_displayed_data = 12 else
                  MemDataAdded      when select_displayed_data = 13 else
                  RegWriteAddr_ext  when select_displayed_data = 14 else
                  RegWriteData      when select_displayed_data = 15;
                  
SSD_DISPLAY: SSD port map(
    clk => clk,
    rst => rst,
    data => displayed_data(15 downto 0),
    an => an,
    cat => seg
);                   
                  
end Behavioral;
