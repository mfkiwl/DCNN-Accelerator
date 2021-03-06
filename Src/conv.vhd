library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity conv is
	port(clk      : in  std_logic;
	     win, fil : in  data_type(0 to 4, 0 to 4);
	     ws   : in std_logic;
	     data     : out std_logic_vector(7 downto 0)
	    );
end entity conv;

architecture conv_arch of conv is
	signal mul : data_type(0 to 4, 0 to 4);
	signal adderOut : std_logic_vector(12 downto 0);
begin
	both0 : entity work.booth
		port map(win(0, 0), fil(0, 0), mul(0, 0));
	both1 : entity work.booth
		port map(win(0, 1), fil(0, 1), mul(0, 1));
	both2 : entity work.booth
		port map(win(0, 2), fil(0, 2), mul(0, 2));
	both3 : entity work.booth
		port map(win(0, 3), fil(0, 3), mul(0, 3));
	both4 : entity work.booth
		port map(win(0, 4), fil(0, 4), mul(0, 4));
	both5 : entity work.booth
		port map(win(1, 0), fil(1, 0), mul(1, 0));
	both6 : entity work.booth
		port map(win(1, 1), fil(1, 1), mul(1, 1));
	both7 : entity work.booth
		port map(win(1, 2), fil(1, 2), mul(1, 2));
	both8 : entity work.booth
		port map(win(1, 3), fil(1, 3), mul(1, 3));
	both9 : entity work.booth
		port map(win(1, 4), fil(1, 4), mul(1, 4));
	both10 : entity work.booth
		port map(win(2, 0), fil(2, 0), mul(2, 0));
	both12 : entity work.booth
		port map(win(2, 1), fil(2, 1), mul(2, 1));
	both13 : entity work.booth
		port map(win(2, 2), fil(2, 2), mul(2, 2));
	both14 : entity work.booth
		port map(win(2, 3), fil(2, 3), mul(2, 3));
	both15 : entity work.booth
		port map(win(2, 4), fil(2, 4), mul(2, 4));
	both16 : entity work.booth
		port map(win(3, 0), fil(3, 0), mul(3, 0));
	both17 : entity work.booth
		port map(win(3, 1), fil(3, 1), mul(3, 1));
	both18 : entity work.booth
		port map(win(3, 2), fil(3, 2), mul(3, 2));
	both19 : entity work.booth
		port map(win(3, 3), fil(3, 3), mul(3, 3));
	both20 : entity work.booth
		port map(win(3, 4), fil(3, 4), mul(3, 4));
	both21 : entity work.booth
		port map(win(4, 0), fil(4, 0), mul(4, 0));
	both22 : entity work.booth
		port map(win(4, 1), fil(4, 1), mul(4, 1));
	both23 : entity work.booth
		port map(win(4, 2), fil(4, 2), mul(4, 2));
	both24 : entity work.booth
		port map(win(4, 3), fil(4, 3), mul(4, 3));
	both25 : entity work.booth
		port map(win(4, 4), fil(4, 4), mul(4, 4));
	
	adder : entity work.adder
		port map(mul,ws, adderOut);
	data <= adderOut(7 downto 0);
end conv_arch;
