library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity dma is
	port(clk, stride, start, ws, read_win, reset : in  std_logic;
	     cell_to_write                           : in  std_logic_vector(7 downto 0);
	     ram_we                                  : in  std_logic;
	     done, done_wr                           : out std_logic := '0';
	     win_out                                 : out data_type(0 to 4, 0 to 4);
	     fil_out                                 : out data_type(0 to 4, 0 to 4)
	    );
end entity dma;

architecture dma_arch of dma is
	signal addr_d, addr_q, mar, addr_inc, mar_d, addr_inc_last : std_logic_vector(17 downto 0);
	signal addr_new, new_row, init_addr                        : std_logic_vector(17 downto 0);
	signal wr_addr_d, wr_addr                                  : std_logic_vector(17 downto 0);
	signal mdr, mdr_tmp                                        : std_logic_vector(39 downto 0);
	signal reset_cache                                         : std_logic;
	signal endof_row                                           : std_logic;
	signal cnt, init_cnt, cnt_d                                : std_logic_vector(2 downto 0);
	signal stride_val                                          : integer;
	constant columns                                           : integer                       := 256;
	constant outp_addr                                         : std_logic_vector(17 downto 0) := "010000000000100000";
	constant filter_addr                                       : std_logic_vector(17 downto 0) := "010000000000000000";
	constant inpt_addr                                         : std_logic_vector(17 downto 0) := "000000000000000000";
	signal done_s, done_wr_s, enable_mar                       : std_logic                     := '0';
	signal state                                               : integer                       := 0;
begin
	ram : entity work.ram
		port map(clk, ram_we, mar, wr_addr, cell_to_write, mdr);
	cache : entity work.cache
		port map(clk, start, ws, read_win, cnt, mdr_tmp, win_out, fil_out);
	window_addr_buffer : entity work.internal_buffer_beta
		generic map(n => 18)
		port map(addr_d, addr_q, inpt_addr, reset, clk, '1');
	cnt_buffer : entity work.internal_buffer_beta
		generic map(n => 3)
		port map(cnt_d, cnt, init_cnt, reset, clk, '1');
	mar_buffer : entity work.internal_buffer_beta
		generic map(n => 18)
		port map(mar_d, mar, init_addr, reset, clk, '1');

	write_addr_buffer : entity work.internal_buffer_beta
		generic map(n => 18)
		port map(wr_addr_d, wr_addr, outp_addr, reset, clk, '1');

	init_cnt   <= "101" when ws = '1' else "011";
	stride_val <= 2 when stride = '1' else 1;

	-- TODO calculate endof_row
	addr_inc      <= std_logic_vector(unsigned(addr_q) + stride_val);
	addr_inc_last <= std_logic_vector(unsigned(addr_q) + stride_val + unsigned(init_cnt) - 1);
	endof_row     <= '0' when addr_inc_last(17 downto 8) = addr_q(17 downto 8) else '1';
	new_row       <= std_logic_vector(unsigned(addr_q(17 downto 8)) + 1) & x"00";

	addr_new <= new_row when endof_row = '1' else addr_inc;

	mdr_tmp(39 downto 16) <= mdr(39 downto 16);
	mdr_tmp(15 downto 0)  <= mdr(15 downto 0) when ws = '1' else (others => '0');
	done                  <= done_s;
	done_wr               <= done_wr_s;

	init_addr <= addr_q when read_win = '1' else filter_addr;

	process(clk, reset, start, done_s)
	begin
		if reset = '1' then
			cnt_d     <= init_cnt;
			done_s    <= '0';
			done_wr_s <= '0';
			addr_d    <= inpt_addr;
			wr_addr_d <= outp_addr;
			mar_d     <= init_addr;
			state     <= 1;
		elsif state = 1 then
			if start = '1' then
				wr_addr_d <= std_logic_vector(unsigned(wr_addr) + 1);
				cnt_d     <= init_cnt;
				done_s    <= '0';
				done_wr_s <= '0';
				mar_d     <= init_addr;
				state     <= 2;
			end if;
		elsif state = 2 then
			if done_s = '1' then
				if read_win = '1' then
					state  <= 3;
				else
					state  <= 1;
				end if;
			elsif cnt_d = "000" then
				if start = '1' then
					done_s <= '1';
					cnt_d  <= init_cnt;
					if read_win = '0' then
						mar_d <= inpt_addr;
					else
						mar_d <= addr_new;
					end if;
					if read_win = '1' then
						addr_d <= addr_new;
					else
						addr_d <= addr_q;
					end if;
				end if;

			elsif rising_edge(clk) then
				if start = '1' then
					cnt_d <= std_logic_vector(unsigned(cnt) - 1);
					if read_win = '1' then
						mar_d <= std_logic_vector(unsigned(mar) + 256);
					else
						mar_d <= std_logic_vector(unsigned(mar) + unsigned(init_cnt));
					end if;
				else
					cnt_d <= cnt;
					mar_d <= mar;
				end if;
			end if;
		elsif state = 3 then
			if falling_edge(clk) then
				if ram_we = '1' then
					done_wr_s <= '1';
					state     <= 1;
				end if;
			end if;
		else
			cnt_d     <= cnt;
			addr_d    <= addr_q;
			wr_addr_d <= wr_addr;
		end if;
	end process;
end dma_arch;
