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

signal rstBtn: std_logic;
signal displayed_data: std_logic_vector(15 downto 0) := (others => '0');

begin

-- declare logic associated to each button
rstBtn <= btnC;

-- instantiate the 7 segment display
SSD_Display: SSD port map(
                clk => clk,
                rst => rstBtn,
                data => sw,
                an => an,
                cat => seg);  

led <= sw;

end Behavioral;
