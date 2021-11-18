library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MipsDefinitions.all;

entity Memory is
  Port ( 
      clk:                in std_logic;
      rst:                in std_logic;
      Flush:              in std_logic;
      mem_control:        in t_mem_control_signals;
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
      mem_wb_RegWriteAddr:out std_logic_vector(4 downto 0)
      );
end Memory;

architecture Behavioral of Memory is

signal data_mem :            t_data_mem_array := c_data_mem_init_data;
signal mem_read_data:        std_logic_vector(31 downto 0);
signal mem_read_byte_data:   std_logic_vector(31 downto 0);
signal mem_write_byte_data:  std_logic_vector(31 downto 0);

begin

mem_write_byte_data <= B when mem_control.SB = '0' else X"000000" & B(7 downto 0);

process(clk,rst)
begin
    if rst = '1' then
        data_mem <= c_data_mem_init_data;
    elsif rising_edge(clk) then
        if mem_control.MemWrite = '1' then   
            data_mem(conv_integer(AluResult)) <= mem_write_byte_data;
        end if;
    end if;   
end process;

mem_read_data <= data_mem(conv_integer(AluResult)) when mem_control.MemRead = '1';
mem_read_byte_data <= mem_read_data when mem_control.LB = '0' else X"000000" & mem_read_data(7 downto 0);

MEM_WB_PIPE_REGISTER: process(clk,Flush)
begin
    if Flush = '1' then
        mem_wb_pc <= (others => '0');
        mem_wb_AluResult <= (others => '0');
        mem_wb_MemData <= (others => '0');
        mem_wb_MemDataInc <= (others => '0');
        mem_wb_Binc <= (others => '0');
        mem_wb_MemDataAdded <= (others => '0');
        mem_wb_RegWriteAddr <= (others => '0');
    elsif rising_edge(clk) then
        mem_wb_pc <= pc;
        mem_wb_AluResult <= AluResult;
        mem_wb_MemData <= mem_read_byte_data;
        mem_wb_MemDataInc <= mem_read_data + 1;
        mem_wb_Binc <= B + 1;
        mem_wb_MemDataAdded <= mem_read_data + B;
        mem_wb_RegWriteAddr <= RegWriteAddr;
   end if;         
end process;

end Behavioral;
