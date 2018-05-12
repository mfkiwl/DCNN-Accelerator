library ieee;
use ieee.std_logic_1164.all;

entity dff_beta is 
	port (	d, rst, clk, enable : in std_logic;
		q : out std_logic;
		init	: in std_logic);
end entity dff_beta;

architecture dff_beta_arch of dff_beta is
begin
	process(clk, rst)
	begin
		if rst = '1' then
			q <= init;
		elsif falling_edge(clk) then
			if enable = '1' then
				q <= d;
			end if;
		end if;
	end process;
end dff_beta_arch;