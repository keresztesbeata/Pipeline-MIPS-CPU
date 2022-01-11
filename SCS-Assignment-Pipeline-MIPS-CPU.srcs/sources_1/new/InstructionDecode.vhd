library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MipsDefinitions.all;

entity InstructionDecode is
  Port (
      clk:               in std_logic;
      en:                in std_logic;
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
end InstructionDecode;

architecture Behavioral of InstructionDecode is

component ControlUnit is
   Port ( 
      instruction:       in std_logic_vector(31 downto 0);
      if_control:        out t_if_control_signals;
      id_control:        out t_id_control_signals;
      ex_control:        out t_ex_control_signals;
      mem_control:       out t_mem_control_signals;
      wb_control:        out t_wb_control_signals  
      );      
end component;      

component Comparator
Port ( 
      a:        in std_logic_vector(31 downto 0);
      b:        in std_logic_vector(31 downto 0);
      less:     out std_Logic;
      equal:    out std_logic;
      greater:  out std_logic
  );
end component;
 
signal ext_imm:                 std_logic_vector(31 downto 0):= (others => '0');
signal less, equal, greater:    std_logic := '0';
signal read_data0, read_data1:  std_logic_vector(31 downto 0);
signal comp_b:                  std_logic_vector(31 downto 0);
signal reg_file_data:           t_reg_file_array := c_reg_file_init_data;

signal if_control:              t_if_control_signals;
signal id_control:              t_id_control_signals;
signal ex_control:              t_ex_control_signals;
signal mem_control:             t_mem_control_signals;
signal wb_control:              t_wb_control_signals;

begin

CU: ControlUnit port map( 
      instruction => instruction,
      if_control => if_control,
      id_control => id_control,
      ex_control => ex_control,
      mem_control => mem_control,
      wb_control => wb_control  
);    

id_if_control <= if_control;

jump_address <= "000000" & instruction(25 downto 0);

ext_imm(15 downto 0) <= instruction(15 downto 0);
-- zero or sign extend immediate
ext_imm(31 downto 16) <= (others => instruction(15)) when id_control.ExtOp = '1' else (others => '0');

branch_address <= pc + read_data1 when if_control.Bezr = '1' else pc + ext_imm;
 
PCSrc <= (if_control.Bltzal and less) or (if_control.Bezr and equal) or (if_control.Bgt and greater);

comp_b <= (others => '0') when if_control.Bezr = '1' or if_control.Bltzal = '1' else read_data1;

COMPARATOR_UNIT: Comparator port map(
    a => read_data0,
    b => comp_b,
    less => less,
    equal => equal,
    greater => greater
    );
 
REGISTER_FILE: process(clk, rst)
begin
    if rst = '1' then
       reg_file_data <= c_reg_file_init_data;
    elsif falling_edge(clk) then
       if en = '1' and RegWrite = '1' then
          reg_file_data(conv_integer(write_addr)) <= write_data;
       end if;
    end if;        
end process;

read_data0 <= reg_file_data(conv_integer(instruction(25 downto 21)));
read_data1 <= reg_file_data(conv_integer(instruction(20 downto 16)));

register_address <= read_data0;

ID_EX_PIPE_REGISTER: process(clk, Flush)
begin
    if Flush = '1' then
       id_ex_pc <= (others => '0');
       id_ex_A <= (others => '0');
       id_ex_B <= (others => '0');
       id_ex_imm <= (others => '0');
       id_ex_sa <= (others => '0');
       id_ex_rt <= (others => '0');
       id_ex_rd <= (others => '0');
    elsif rising_edge(clk) then
       if(en = '1') then
           id_ex_pc <= pc;
           id_ex_A <= read_data0;
           id_ex_B <= read_data1;
           id_ex_imm <= ext_imm;
           id_ex_sa <= instruction(10 downto 6);
           id_ex_rt <= instruction(20 downto 16);
           id_ex_rd <= instruction(15 downto 11);
           id_ex_control <= ex_control;
           id_mem_control <= mem_control;
           id_wb_control <= wb_control;
       end if;    
    end if;             
end process;

end Behavioral;
