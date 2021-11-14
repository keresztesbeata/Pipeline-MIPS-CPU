library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MipsDefinitions.all;

entity InstructionDecode is
  Port (
      clk:               in std_logic;
      rst:               in std_logic;
      Flush:             in std_logic;
      RegWrite:          in std_logic; -- comes from WB pipel stage
      pc:                in std_logic_vector(31 downto 0);
      instruction:       in std_logic_vector(31 downto 0);
      write_addr:        in std_logic_vector(31 downto 0);
      write_data:        in std_logic_vector(31 downto 0);
      branch_address:    out std_logic_vector(31 downto 0);
      jump_address:      out std_logic_vector(31 downto 0);
      register_address:  out std_logic_vector(31 downto 0);
      PCSrc:             out std_logic;
      if_control:        out t_if_control_signals;
      id_ex_pc:          out std_logic_vector(31 downto 0); 
      id_ex_A:           out std_logic_vector(31 downto 0);
      id_ex_B:           out std_logic_vector(31 downto 0);
      id_ex_imm:         out std_logic_vector(31 downto 0);
      id_ex_sa:          out std_logic_vector(4 downto 0);
      id_ex_func:        out std_logic_vector(5 downto 0);
      id_ex_rt:          out std_logic_vector(5 downto 0);
      id_ex_rd:          out std_logic_vector(5 downto 0);
      id_ex_control:     out t_ex_control_signals;
      id_mem_control:    out t_mem_control_signals;
      id_wb_control:     out t_wb_control_signals    
   );
end InstructionDecode;

architecture Behavioral of InstructionDecode is

component ControlUnit is
  Port ( 
      clk:               in std_logic;
      rst:               in std_logic;
      instruction:       in std_logic_vector(31 downto 0);
      if_control:        out t_if_control_signals;
      id_control:        out t_id_control_signals;
      ex_control:        out t_ex_control_signals;
      mem_control:       out t_mem_control_signals;
      wb_control:        out t_wb_control_signals  
      );    
end component;      

signal ext_imm:                 std_logic_vector(31 downto 0):= (others => '0');
signal less, equal, greater:    std_logic := '0';
signal read_data0, read_data1:  std_logic_vector(31 downto 0);
signal reg_file_data:           t_reg_file_array := c_reg_file_init_data;

signal if_control:              t_if_control_signals;
signal id_control:              t_id_control_signals;
signal ex_control:              t_ex_control_signals;
signal mem_control:             t_mem_control_signals;
signal wb_control:              t_wb_control_signals;

begin

CU: ControlUnit port map( 
      clk => clk,
      rst => rst,
      instruction => instruction,
      if_control => if_control,
      id_control => id_control,
      ex_control => ex_control,
      mem_control => mem_control,
      wb_control => wb_control  
);    

jump_address <= pc(31 downto 26) & instruction(25 downto 0);

ext_imm(15 downto 0) <= instruction(15 downto 0);
-- zero or sign extend immediate
ext_imm(31 downto 16) <= (others => instruction(15)) when id_control.ExtOp = '1' else (others => '0');

branch_address <= pc + ext_imm;

PCSrc <= (if_control.Bltzal and less) or (if_control.Bezr and equal) or (if_control.Bgt and greater);

COMPARATOR: process(read_data0,read_data1)
variable a, b: integer;
begin
    a := conv_integer(read_data0);
    b := conv_integer(read_data1);
    less <= '0';
    equal <= '0';
    greater <= '0';
    if a < b then
        less <= '1';
    elsif a = b then
        equal <= '1';
    else
        greater <= '1';
    end if;            
end process;
 
REGISTER_FILE: process(clk, rst)
variable read_addr0, read_addr1: std_logic_vector(31 downto 0);
begin
    if rst = '1' then
       reg_file_data <= c_reg_file_init_data;
    elsif falling_edge(clk) then
       if RegWrite = '1' then
          reg_file_data(conv_integer(write_addr)) <= write_data;
       end if;
    end if;        
end process;

ID_EX_PIPE_REGISTER: process(clk, Flush)
begin
    if Flush = '1' then
       id_ex_pc <= (others => '0');
       id_ex_A <= (others => '0');
       id_ex_B <= (others => '0');
       id_ex_imm <= (others => '0');
       id_ex_sa <= (others => '0');
       id_ex_func <= (others => '0');
       id_ex_rt <= (others => '0');
       id_ex_rd <= (others => '0');
    elsif rising_edge(clk) then
       id_ex_pc <= pc + 1;
       id_ex_A <= reg_file_data(conv_integer(instruction(25 downto 21)));
       id_ex_B <= reg_file_data(conv_integer(instruction(20 downto 16)));
       id_ex_imm <= ext_imm;
       id_ex_sa <= instruction(10 downto 6);
       id_ex_func <= instruction(5 downto 0);
       id_ex_rt <= instruction(20 downto 16);
       id_ex_rd <= instruction(15 downto 11);
       id_ex_control <= ex_control;
       id_mem_control <= mem_control;
       id_wb_control <= wb_control;
    end if;             
end process;

end Behavioral;
