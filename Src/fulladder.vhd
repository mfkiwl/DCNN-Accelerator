library ieee;
use ieee.std_logic_1164.all;

entity fulladder is 
	port (	a, b , c : in std_logic;
		sum, carry : out std_logic	);
end entity fulladder;

architecture data_flow of fulladder is
begin
	sum <= a xor b xor c;
	carry <= (a and b) when c = '0'
		else (a or b);
end data_flow;

