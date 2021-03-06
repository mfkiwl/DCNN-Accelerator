library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity cache is
	port(
		clk       : in  std_logic;
		we, reset : in  std_logic;
		wr_type   : in  std_logic;
		address   : in  std_logic_vector(2 downto 0);
		datain    : in  std_logic_vector(39 downto 0);
		win_out   : out data_type(0 to 4, 0 to 4);
		fil_out   : out data_type(0 to 4, 0 to 4));

end entity cache;

architecture cache_arch of cache is
	signal cache_filter : data_type(0 to 4, 0 to 4);
	signal cache_window : data_type(0 to 4, 0 to 4);

begin
	process(clk) is
	begin
		if falling_edge(clk) then
			if address = "000" then
			
			elsif we = '1' then
				if wr_type = '0' then
					cache_filter(to_integer(unsigned(address) - 1), 0) <= datain(7 downto 0);
					cache_filter(to_integer(unsigned(address) - 1), 1) <= datain(15 downto 8);
					cache_filter(to_integer(unsigned(address) - 1), 2) <= datain(23 downto 16);
					cache_filter(to_integer(unsigned(address) - 1), 3) <= datain(31 downto 24);
					cache_filter(to_integer(unsigned(address) - 1), 4) <= datain(39 downto 32);
				else
					cache_window(to_integer(unsigned(address) - 1), 0) <= datain(7 downto 0);
					cache_window(to_integer(unsigned(address) - 1), 1) <= datain(15 downto 8);
					cache_window(to_integer(unsigned(address) - 1), 2) <= datain(23 downto 16);
					cache_window(to_integer(unsigned(address) - 1), 3) <= datain(31 downto 24);
					cache_window(to_integer(unsigned(address) - 1), 4) <= datain(39 downto 32);
				end if;
			end if;

		end if;
	end process;
	win_out <= cache_window;
	fil_out <= cache_filter;
end cache_arch;
