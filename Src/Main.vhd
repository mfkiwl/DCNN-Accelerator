library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity main is
	port(clk, algo, ws, start, stride        : in  std_logic;
	     done                                : out std_logic
	    );
end entity main;

architecture main_arch of main is
	signal cnt                         : std_logic_vector(15 downto 0);
	signal init_cnt                    : std_logic_vector(15 downto 0);
	signal dma_start, read_win, ram_we : std_logic := '0';
	signal cell_to_write               : std_logic_vector(7 downto 0);
	signal dma_done                    : std_logic ;
	signal win, fil                    : data_type(0 to 4, 0 to 4);
	signal acc_start                   : std_logic := '0';
	signal dma_done_wr                 : std_logic;
	signal debug1,debug2,debug3,debug4 : std_logic := '0';
begin
dma : entity work.dma
	port map(clk, stride, dma_start, ws, read_win, start, cell_to_write, ram_we, dma_done, dma_done_wr, win, fil);
acc : entity work.acc
	port map(clk, acc_start, algo, ws, win, fil, cell_to_write);

init_cnt <= std_logic_vector(to_unsigned(64517,16)) when ws = '0' and stride = '0'
	else std_logic_vector(to_unsigned(32259,16)) when ws = '0'
	else std_logic_vector(to_unsigned(63505,16)) when stride = '0'
	else std_logic_vector(to_unsigned(31753,16));

process(start,dma_done,dma_done_wr,read_win)
begin
	if rising_edge(start) then
		cnt       <= init_cnt;
		dma_start <= '1';
		read_win  <= '0';
		done <= '0';
		debug1 <= '1';
		debug2 <= '0';
		debug3 <= '0';
		debug4 <= '0';
	elsif  rising_edge(dma_done) then
		acc_start <= '1';
		if read_win = '0' then
			read_win <= '1';
		else
			ram_we <= '1';
		end if;
		dma_start <= '0';
		debug2 <= '1';
		debug1 <= '0';
		debug3 <= '0';
		debug4 <= '0';
	elsif rising_edge(read_win) then
		dma_start <= '1';
		debug3 <= '1';
		debug2 <= '0';
		debug1 <= '0';
		debug4 <= '0';
	elsif rising_edge(dma_done_wr) then	
		if cnt = x"0000"  then
			done <= '1';
		else
			cnt <= std_logic_vector(unsigned(cnt) - 1);
			dma_start <= '1';
			ram_we <= '0';
		end if;
		debug4 <= '1';
		debug2 <= '0';
		debug3 <= '0';
		debug1 <= '0';
	end if;
end process;

end main_arch;
