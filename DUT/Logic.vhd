library ieee;
use ieee.std_logic_1164.all;
-----------------------------------
entity logic is
	GENERIC (n : INTEGER := 8);
	port(x, y: in std_logic_vector (n-1 downto 0);
	ALU_func: std_logic_vector (2 downto 0);
	res : out std_logic_vector(n-1 downto 0));
	end logic;
	
-------------------------------------------------------
architecture bool_logic of logic is
begin
with ALU_func select
	res <= not(y) when "000",    --- not(y) bitwise operation
		   y or x when "001",	 --- x or y bitwise operation
		   y and x when "010",   --- x and y bitwise operation
		   y xor x when "011",   --- x xor y bitwise operation
		   y nor x when "100",   --- x nor y bitwise operation
		   y nand x when "101",  --- x nand y bitwise operation
		   y xnor x when "111",  --- x xnor y bitwise operation
		   (others => '0') when others;  --- Otherwise -The output is the zero output
	end bool_logic; 