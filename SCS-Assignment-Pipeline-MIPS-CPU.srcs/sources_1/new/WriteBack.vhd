library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MipsDefinitions.all;

entity WriteBack is
    Port ( 
      wb_control:         in t_wb_control_signals;
      pc:                 in std_logic_vector(31 downto 0);
      AluResult:          in std_logic_vector(31 downto 0);
      Binc:               in std_logic_vector(31 downto 0);
      MemData:            in std_logic_vector(31 downto 0);
      MemDataInc:         in std_logic_vector(31 downto 0);
      MemDataAdded:       in std_logic_vector(31 downto 0);
      RegWriteData:       out std_logic_vector(31 downto 0)
      );
end WriteBack;

architecture Behavioral of WriteBack is

begin

RegWriteData <= pc when wb_control.LinkRetAddr = '1' else
                   AluResult when wb_control.MemToReg = "000" else
                   MemData when wb_control.MemToReg = "001" else
                   Binc when wb_control.MemToReg = "010" else
                   MemDataInc when wb_control.MemToReg = "011" else
                   MemDataAdded when wb_control.MemToReg = "100";
                   
end Behavioral;
