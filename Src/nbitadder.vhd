library ieee;
use ieee.std_logic_1164.all;

entity nbitadder is 
	generic (n : integer := 16);
	port (	a, b : in std_logic_vector (n - 1 downto 0);
		cin : in std_logic;
		sum : out std_logic_vector (n - 1 downto 0);
		cout : out std_logic	);
end entity nbitadder;

architecture nbitadder_arch of nbitadder is
	component fulladder is
		port (	a, b , c : in std_logic;
		sum, carry : out std_logic	);
	end component;
	signal temp : std_logic_vector (n - 1 downto 0);
begin
	u: fulladder port map(a(0), b(0), cin, sum(0), temp(0));
	loop0: for i in 1 to n-1 generate
          u0: fulladder port map (a(i), b(i), temp(i - 1), sum(i), temp(i));
    end generate;
    cout <= temp(n-1);
end nbitadder_arch;
