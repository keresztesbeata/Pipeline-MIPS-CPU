library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MipsDefinitions.all;

entity ControlUnit is
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
end ControlUnit;

architecture Behavioral of ControlUnit is

begin

CONTROL_SIGNALS: process(instruction)
variable opcode, func:    std_logic_vector(5 downto 0);
begin
    opcode := instruction(31 downto 26);
    func := instruction(5 downto 0);
    
    if_control <= (PCWrite => '0', Bezr => '0', Bltzal => '0', Bgt => '0', Jal => '0', Jalr => '0', Jr => '0');
    id_control <= (ExtOp => '0');
    ex_control <= (RegDest => "00");
    mem_control <= (MemRead => '0', MemWrite => '0');
    wb_control <= (RegWrite => '0');
    
    case opcode is
        when "000000" => 
            case func is
                when "000000" => 
                when "000001" =>
                when "000010" =>
                when others =>
            end case;
        when "000001" =>
        when "000010" =>
        when others =>            
    end case;    
end process; 


end Behavioral;
