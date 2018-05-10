library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity dma is
	port(clk, stride, start, ws, read_win, reset : in  std_logic;
	     cell_to_write                           : in  std_logic_vector(7 downto 0);
	     ram_we                                  : in  std_logic;
	     done, done_wr                           : out std_logic;
	     win_out                                 : out data_type(0 to 4, 0 to 4);
	     fil_out                                 : out data_type(0 to 4, 0 to 4)
	    );
end entity dma;

architecture dma_arch of dma is
	signal addr_d, addr_q, mar, addr_inc : std_logic_vector(17 downto 0);
	signal addr_new, new_row             : std_logic_vector(17 downto 0);
	signal wr_addr_d, wr_addr            : std_logic_vector(17 downto 0);
	signal mdr, mdr_tmp                  : std_logic_vector(39 downto 0);
	signal reset_cache                   : std_logic;
	signal endof_row                     : std_logic;
	signal cnt, init_cnt                 : std_logic_vector(2 downto 0);
	signal stride_val                    : integer;
	constant columns                     : integer                       := 256;
	constant outp_addr                   : std_logic_vector(17 downto 0) := "010000000000100000";
	constant filter_addr                 : std_logic_vector(17 downto 0) := "010000000000000000";
	constant inpt_addr                   : std_logic_vector(17 downto 0) := "000000000000000000";
begin
	ram : entity work.RAM
		port map(clk, ram_we, mar, wr_addr, cell_to_write, mdr);
	cache : entity work.Cache
		port map(clk, start, reset_cache, read_win, cnt, mdr_tmp, win_out, fil_out);
	window_addr_buffer : entity work.internal_buffer_beta
		generic map(n => 18)
		port map(addr_d, addr_q, inpt_addr, reset, clk);
	write_addr_buffer : entity work.internal_buffer_beta
		generic map(n => 18)
		port map(wr_addr_d, wr_addr, outp_addr, reset, clk);

	init_cnt   <= "101" when ws = '1' else "011";
	stride_val <= 2 when stride = '1' else 1;

	-- TODO calculate endof_row
	addr_inc  <= std_logic_vector(unsigned(addr_q) + stride_val);
	endof_row <= '0' when addr_inc(17 downto 8) = addr_q(17 downto 8) else '1';
	new_row   <= std_logic_vector(unsigned(addr_q(17 downto 8)) + 1) & x"00";

	addr_new <= new_row when endof_row = '1' else addr_inc;

	mdr_tmp(39 downto 16) <= mdr(39 downto 16);
	mdr_tmp(15 downto 0)  <= mdr(15 downto 0) when ws = '1' else (others => '0');

	process(start)
	begin
		if rising_edge(start) then
			cnt         <= init_cnt;
			done        <= '0';
			reset_cache <= '1';
			done_wr     <= '0';
			if read_win = '1' then
				mar <= addr_q;
			else
				mar <= filter_addr;
			end if;
		end if;
	end process;
	process(clk)
	begin
		if cnt = "000" then
			done        <= '1';
			reset_cache <= '0';
			if read_win = '1' then
				addr_d <= addr_new;
			else
				addr_d <= addr_q;
			end if;
		else
			if rising_edge(clk) then
				if read_win = '1' then
					mar <= std_logic_vector(unsigned(mar) + 256);
				else
					mar <= std_logic_vector(unsigned(mar) + unsigned(init_cnt));
				end if;
				cnt <= std_logic_vector(unsigned(cnt) - 1);
			end if;
		end if;
	end process;

	process(ram_we, clk)
	begin
		if rising_edge(clk) then
			if ram_we = '1' then
				wr_addr_d <= std_logic_vector(unsigned(wr_addr) + 1);
			else
				wr_addr_d <= wr_addr;
			end if;
		end if;
		if falling_edge(clk) then
			if ram_we = '1' then
				done_wr <= '1';
			end if;
		end if;

	end process;
end dma_arch;
