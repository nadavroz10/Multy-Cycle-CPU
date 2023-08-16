library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;


----------------------------------
 
entity shifter is
 GENERIC (n : INTEGER := 8; k : integer := 3); -- k = log2(n) 
port (x,y : in std_logic_vector (n-1 downto 0);
	ALU_func: in std_logic_vector (2 downto 0);
	res : out std_logic_vector (n-1 downto 0);
	cout : out std_logic);
end shifter;
---------------------------------

architecture shifter_arch of shifter is
subtype vector is std_logic_vector (n-1 downto 0);
type matrix is array (n-1 downto 0) of vector; 
signal rowl, rowr: matrix;          -- One matrix for shl and another for shr.
signal shifts: integer range 0 to n-1;   -- Number of shifts
begin
		
		shifts <= to_integer(unsigned(x(k-1 downto 0)));   --Converting the shifts number to integer
		rowl(0) <= y;
		rowr(0) <= y;
		g1: for i in 1 to n-1 generate
			rowl(i) <= rowl(i-1)(n-2 downto 0) & '0';   --- Shift left 
			rowr(i) <= '0' & rowr(i-1)(n-1 downto 1);	--- Shift right
		end generate;
		with ALU_func select 
		res <= rowl(shifts) when "000",   
			   rowr (shifts) when "001",
			   (others => '0') when others;             --- The output to undefined ALU_func input is 0's vector
		cout <= '0' when shifts = 0 else                ---Cout calculation
				y(n-shifts) when ALU_func= "000" else
			    y(shifts-1) when ALU_func= "001" else
			   '0';										--- When ALU_func is undefined, Cout is 0. 
end shifter_arch;