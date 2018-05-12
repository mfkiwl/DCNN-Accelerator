library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity booth is
	port(
	     inp1, inp2 : in  std_logic_vector(7 downto 0);
	     out1       : out std_logic_vector(7 downto 0)
	    );
end entity booth;

architecture booth_arch of booth is
begin

	process(inp1, inp2)
		variable m     : std_logic_vector(7 downto 0);
		variable q     : std_logic_vector(7 downto 0);
		variable q_pre : std_logic;
		variable a     : std_logic_vector(7 downto 0);
	begin
		m     := inp2;
		a     := x"00";
		q     := inp1;
		q_pre := '0';
		for i in 0 to 7 loop
			if q(0) = '0' and q_pre = '1' then
				a     := a + m;
				q_pre := q(0);
				q     := a(0) & q(7 downto 1);
				a     := q(0) & a(7 downto 1);

			elsif q(0) = '1' and q_pre = '0' then
				a     := a - m;
				q_pre := q(0);
				q     := a(0) & q(7 downto 1);
				a     := q(0) & a(7 downto 1);
			else
				q_pre := q(0);
				q     := a(0) & q(7 downto 1);
				a     := q(0) & a(7 downto 1);
			end if;
		end loop;
		out1  <= q;
	end process;

end booth_arch;
