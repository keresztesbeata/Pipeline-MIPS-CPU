library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.MipsDefinitions.all;

entity MipsPipelineTestBench is
end MipsPipelineTestBench;

architecture Behavioral of MipsPipelineTestBench is
component MipsPipeline is
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
end component;

signal clk:        std_logic;
signal btnU:       std_logic;
signal btnD:       std_logic;
signal btnR:       std_logic;
signal sw:         std_logic_vector(15 downto 0);
signal an:         std_logic_vector(3 downto 0);
signal seg:        std_logic_vector(6 downto 0);
signal led:        std_logic_vector(15 downto 0);
    
begin

MIPS_UT: MipsPipeline port map(
    clk => clk,
    btnU => btnU,
    btnD => btnD,
    btnR => btnR,
    sw => sw,
    an => an,
    seg => seg,
    led => led
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
