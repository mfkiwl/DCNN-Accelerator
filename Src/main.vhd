library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity main is
	port(clk, algo, ws, start, stride, reset : in  std_logic;
	     done                                : out std_logic
	    );
end entity main;

architecture main_arch of main is
	signal cnt                            : std_logic_vector(15 downto 0);
	signal init_cnt                       : std_logic_vector(15 downto 0);
	signal dma_start, read_win, ram_we    : std_logic := '0';
	signal cell_to_write                  : std_logic_vector(7 downto 0);
	signal dma_done                       : std_logic;
	signal win, fil                       : data_type(0 to 4, 0 to 4);
	signal acc_start                      : std_logic := '0';
	signal dma_done_wr                    : std_logic;
	signal debug1, debug2, debug3, debug4 : std_logic := '0';
	signal state                          : integer   := 0;
begin
	dma : entity work.dma
		port map(clk, stride, dma_start, ws, read_win, reset, cell_to_write, ram_we, dma_done, dma_done_wr, win, fil);
	acc : entity work.acc
		port map(clk, acc_start, algo, ws, win, fil, cell_to_write);

	init_cnt <= std_logic_vector(to_unsigned(64517, 16)) when ws = '0' and stride = '0'
		else std_logic_vector(to_unsigned(32259, 16)) when ws = '0'
		else std_logic_vector(to_unsigned(63505, 16)) when stride = '0'
		else std_logic_vector(to_unsigned(31753, 16));

	process(reset , start, dma_done, dma_done_wr, read_win,clk)
	begin
		if reset = '1' then
			state <= 0;
			cnt <= init_cnt;
			dma_start <= '0';
			read_win  <= '0';
			done      <= '0';
			ram_we <= '0';
			acc_start <= '0';
		elsif state = 0 then
			if start = '1' then
				cnt       <= init_cnt;
				dma_start <= '1';
				read_win  <= '0';
				done      <= '0';
				state     <= 1;
			end if;
		elsif state = 1 then
			if dma_done = '1' then
				acc_start <= '1';
				if read_win = '0' then
					read_win <= '1';
					state    <= 2;
				else
					ram_we <= '1';
					state  <= 3;
				end if;
				dma_start <= '0';
			end if;
		elsif state = 2 then
			if read_win = '1' then
				if falling_edge(clk) then
					dma_start <= '1';
					state     <= 1;
				end if;
			end if;
		elsif state = 3 then
			if dma_done_wr = '1' then
				if cnt = x"0000" then
					done  <= '1';
					state <= 4;
				else
					cnt       <= std_logic_vector(unsigned(cnt) - 1);
					dma_start <= '1';
					ram_we    <= '0';
					state     <= 1;
				end if;
			end if;
		end if;
	end process;

end main_arch;
