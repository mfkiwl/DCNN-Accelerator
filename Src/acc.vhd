library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity acc is
	port(clk, start, algo, ws : in  std_logic;
	     win                  : in  data_type(0 to 4, 0 to 4);
	     fil                  : in  data_type(0 to 4, 0 to 4);
	     data                 : out std_logic_vector(7 downto 0)
	    );
end entity acc;

architecture acc_arch of acc is
	signal conv_data, pool_data : std_logic_vector(7 downto 0);
begin
	conv : entity work.conv
		port map(clk, win, fil,ws, conv_data);
	pool : entity work.pool
		port map(clk, ws, win, pool_data);
	data <= conv_data when algo  = '0' else pool_data;
end acc_arch;
