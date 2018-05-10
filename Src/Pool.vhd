library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity pool is
	port(clk, ws : in  std_logic;
	     win     : in  data_type(0 to 4, 0 to 4);
	     data    : out std_logic_vector(7 downto 0)
	    );
end entity pool;

architecture pool_arch of pool is
	signal adderOut : std_logic_vector(12 downto 0);
begin
	adder : entity work.adder
		port map(win, adderOut);
	data <= adderOut(10 downto 3) when ws = '0' else adderOut(12 downto 5);
end pool_arch;
