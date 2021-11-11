----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/04/2021 09:18:42 PM
-- Design Name: 
-- Module Name: RegisterFile - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegisterFile is
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
end RegisterFile;

architecture Behavioral of RegisterFile is

type T_RF_ARRAY is array(0 to 31) of std_logic_vector(31 downto 0); 
-- initialize the first 10 registers with values
signal rf: T_RF_ARRAY := (0 => x"00000000",
                          1 => x"00000001",
                          2 => x"00000002",
                          3 => x"00000003",
                          4 => x"00000004",
                          5 => x"00000005",
                          6 => x"00000006",
                          7 => x"00000007",
                          8 => x"00000008",
                          9 => x"00000009",
                          others => (others => '0')
                          );

begin

process(clk, rst) 
begin
    if rst = '1' then
        -- erase the whole content of all the registers
        rf <= (others => (others => '0'));
    elsif falling_edge(clk) then
        -- synchronous write on falling edge of the clock
        if write = '1' then
            rf(to_integer(unsigned(wa))) <= wd;
        end if;
    end if;         
end process;

-- asynchronous read
rd1 <= rf(to_integer(unsigned(ra1))) when read = '1' else (others => 'Z');
rd2 <= rf(to_integer(unsigned(ra2))) when read = '1' else (others => 'Z');

end Behavioral;
