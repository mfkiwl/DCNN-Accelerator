library ieee;
use ieee.std_logic_1164.all;

entity internal_buffer_beta is
	generic(n : integer := 16);
	port(buffer_in   : in  std_logic_vector(n - 1 downto 0);
	     buffer_out  : out std_logic_vector(n - 1 downto 0);
	     initial_val : in  std_logic_vector(n - 1 downto 0);
	     rst, clk ,en   : in  std_logic);
end entity internal_buffer_beta;

architecture internal_buffer_beta_arch of internal_buffer_beta is
	
begin
	l : for i in 0 to n - 1 generate
		u : entity work.dff_beta port map(buffer_in(i), rst, clk, en, buffer_out(i), initial_val(i));
	end generate;
end internal_buffer_beta_arch;
