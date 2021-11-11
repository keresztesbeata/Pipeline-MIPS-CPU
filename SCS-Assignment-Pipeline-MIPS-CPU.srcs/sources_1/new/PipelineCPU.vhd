----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/03/2021 01:26:51 PM
-- Design Name: 
-- Module Name: PipelineCPU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PipelineCPU is
  Port (clk: in std_logic;
        btnU: in std_logic;
        btnL: in std_logic;
        btnD: in std_logic;
        btnR: in std_logic;
        btnC: in std_logic;
        sw: in std_logic_vector(15 downto 0);
        an: out std_logic_vector(3 downto 0);
        seg: out std_logic_vector(6 downto 0);
        led: out std_logic_vector(15 downto 0)
         );
end PipelineCPU;

architecture Behavioral of PipelineCPU is

component SSD is
      Port (clk: in std_logic;
            rst: in std_logic;
            data: in std_logic_vector(15 downto 0);
            an: out std_logic_vector(3 downto 0);
            cat: out std_logic_vector(6 downto 0));
end component;            

component Debouncer is
      Port (clk: in std_logic;
            rst: in std_logic;
            d_in: in std_logic;
            q_out: out std_logic);
end component;    

component MipsCU is
  Port ( opcode: in std_logic_vector(31 downto 0);
         funct: in std_logic_vector(5 downto 0);
         RegDest: out std_logic;
         AluSrc: out std_logic;
         ShiftVar: out std_logic_vector(1 downto 0);
         AluOp: out std_logic_vector(3 downto 0);
         ExtOp: out std_logic;
         MemWrite: out std_logic;
         LB: out std_logic;
         SB: out std_logic;
         MemToReg: out std_logic_vector(2 downto 0);
         RegWrite: out std_logic;
         LinkRetAddr: out std_logic;
         Bgt: out std_logic;
         Bezr: out std_logic;
         Bltzal: out std_logic;
         Jal: out std_logic;
         Jalr: out std_logic;
         Jr: out std_logic
         );
end component;         

component RegisterFile is
    Port ( clk : in std_logic;
           rst : in std_logic;
           read: in std_logic;
           write: in std_logic;
           ra1: in std_logic_vector(4 downto 0);
           ra2: in std_logic_vector(4 downto 0);
           wa: in std_logic_vector(4 downto 0);
           wd: in std_logic_vector(31 downto 0);
           rd1: out std_logic_vector(31 downto 0);
           rd2: out std_logic_vector(31 downto 0));
end component;             

component  ALU is
  Port (  a: in std_logic_vector(31 downto 0);
          b: in std_logic_vector(31 downto 0);
          AluOp: in std_logic_vector(3 downto 0);
          sa: in std_logic_vector(4 downto 0);
          result: out std_logic_vector(31 downto 0));
end component;            

-- clock reset and enable signals
signal rst: std_logic;
signal ce: std_logic;

-- register file signals
signal rs: std_logic_vector(4 downto 0);
signal rt: std_logic_vector(4 downto 0);
signal rd: std_logic_vector(4 downto 0);
signal wa: std_logic_vector(4 downto 0);
signal wd: std_logic_vector(31 downto 0);
signal rd1: std_logic_vector(31 downto 0);
signal rd2: std_logic_vector(31 downto 0);

-- ALU signals
signal a: std_logic_vector(31 downto 0);
signal b: std_logic_vector(31 downto 0);
signal sa: std_logic_vector(4 downto 0);
signal alu_result: std_logic_vector(31 downto 0);

-- control signals for ID stage
type t_control_id is record
    Bezr : std_logic;                
    Bltzal : std_logic;
    Bgt : std_logic;
    Jr : std_logic;
    Jal : std_logic;
    Jalr : std_logic;
    ExtOp  : std_logic;     
end record t_control_id;

signal control_id: t_control_id;

-- control signals for EX stage
type t_control_ex is record
    RegDest : std_logic;
    AluSrc: std_logic;           
    AluOp : std_logic_vector(3 downto 0);
    ShiftVar  : std_logic_vector(1 downto 0);
end record t_control_ex;

signal control_ex: t_control_ex;

-- control signals for MEM stage
type t_control_mem is record
    MemWrite : std_logic;                
    LB : std_logic;
    SB : std_logic;
end record t_control_mem;

signal control_ex_mem: t_control_mem;
signal control_mem: t_control_mem;

-- control signals for WB stage
type t_control_wb is record                
    MemToReg : std_logic_vector(2 downto 0);
    RegWrite : std_logic;
    LinkRetAddr : std_logic;
end record t_control_wb;

signal control_ex_wb: t_control_wb;
signal control_mem_wb: t_control_wb;
signal control_wb: t_control_wb;

signal instruction: std_logic_vector(31 downto 0);

signal displayed_data: std_logic_vector(15 downto 0) := (others => '0');

begin

-- declare logic associated to each button
rst <= btnC;

-- button for enabling the clock: the instruction advances to the next pipeline stage when the button is pressed
BTN_Debouncer: Debouncer port map(
                clk => clk,
                rst => rst,
                d_in => btnR,
                q_out => ce);
                 
-- instantiate the MIPS control unit
MIPS_CU: MipsCU port map(
         opcode => instruction(31 downto 25),
         funct => instruction(5 downto 0),
         RegDest => control_ex.RegDest,
         AluSrc => control_ex.AluSrc,
         ShiftVar => control_ex.ShiftVar,
         AluOp => control_ex.AluOp,
         ExtOp => control_id.ExtOp,
         MemWrite => control_mem.MemWrite,
         LB => control_mem.LB,
         SB => control_mem.SB,
         MemToReg => control_wb.MemToReg,
         RegWrite => control_wb.RegWrite,
         LinkRetAddr => control_wb.LinkRetAddr,
         Bgt => control_id.Bgt,
         Bezr => control_id.Bezr,
         Bltzal => control_id.Bltzal,
         Jal => control_id.Jal,
         Jalr => control_id.Jalr,
         Jr => control_id.Jr);
                          
-- instantiate the register file
REGISTER_FILE: RegisterFile port map(
           clk => clk,
           rst => rst,
           read => '1',
           write => control_wb.RegWrite,
           ra1 => rs,
           ra2 => rt,
           wa => wa,
           wd => wd,
           rd1 => rd1,
           rd2 => rd2);    
           
-- instantiate the ALU unit
 ALU_unit: ALU port map(
          a => a,
          b => b,
          AluOp => control_ex.AluOp,
          sa => sa,
          result => alu_result);
           
-- instantiate the 7 segment display
SSD_Display: SSD port map(
                clk => clk,
                rst => rst,
                data => sw,
                an => an,
                cat => seg);  

led <= sw;

end Behavioral;
