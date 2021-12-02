library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MipsDefinitions.all;

entity Execute is
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
end Execute;

architecture Behavioral of Execute is

component ALU is
   Port ( a:           in std_logic_vector(31 downto 0);
          b:            in std_logic_vector(31 downto 0);
          AluOp:        in t_alu_op;
          sh_amount:    in integer;
          result:       out std_logic_vector(31 downto 0));
end component;          

signal alu_result:      std_logic_vector(31 downto 0);
signal reg_write_addr:  std_logic_vector(4 downto 0);
signal shift_amount:    integer := 0;
signal AluSrcB:         std_logic_vector(31 downto 0);

begin

shift_amount <= conv_integer(sa) when ex_control.ShiftVar = "00" else
                conv_integer(A) when ex_control.ShiftVar = "01" else
                16 when ex_control.ShiftVar = "10";
                
AluSrcB <= B when ex_control.AluSrc = '0' else imm;
                
ALU_UNIT: ALU port map(
    a => A,
    b => AluSrcB,
    AluOp => ex_control.AluOp,
    sh_amount => shift_amount,
    result => alu_result
    ); 
    
reg_write_addr <= rt when ex_control.RegDest = "00" else
                  rd when ex_control.RegDest = "01" else
                  "11111" when ex_control.RegDest = "10";
    
EX_MEM_PIPE_REGISTER: process(clk, Flush)
begin
      if Flush = '1' then
        ex_mem_pc <= (others => '0');
        ex_mem_AluResult <= (others => '0');
        ex_mem_B <= (others => '0');
        ex_mem_control <= (MemRead => '0', MemWrite => '0', SB => '0', LB => '0');
        ex_wb_control <= (RegWrite => '0', LinkRetAddr => '0', MemToReg => "000");
    elsif rising_edge(clk) then
        ex_mem_pc <= pc;
        ex_mem_AluResult <= alu_result;
        ex_mem_B <= B;
        ex_mem_RegWriteAddr <= reg_write_addr;
        ex_mem_control <= mem_control;
        ex_wb_control <= wb_control;
    end if;   
end process;    

end Behavioral;
