library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Debouncer is
  Port (clk:    in std_logic;
        rst:    in std_logic;
        d_in:   in std_logic;
        q_out:  out std_logic);
end Debouncer;

architecture Behavioral of Debouncer is
signal q1, q2, q3 : std_logic;

begin

process(clk)
begin
   if (rising_edge(clk)) then
      if (rst = '1') then
         q1 <= '0';
         q2 <= '0';
         q3 <= '0';
      else
         q1 <= d_in;
         q2 <= q1;
         q3 <= q2;
      end if;
   end if;
end process;

q_out <= q1 and q2 and (not q3);

end Behavioral;
