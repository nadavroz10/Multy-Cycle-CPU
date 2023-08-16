library IEEE;
use ieee.std_logic_1164.all;

package ALU_aux_package is
--------------------------------------------------------
	component ALU is
	GENERIC (n : INTEGER:= 8;
		   k : integer := 3;   -- k=log2(n)
		   m : integer := 4	); -- m=2^(k-1)
	PORT 
	(  
		Y_i,X_i: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		ALUFN_i : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		ALUout_o: OUT STD_LOGIC_VECTOR(n-1 downto 0);
		Nflag_o,Cflag_o,Zflag_o: OUT STD_LOGIC 
	); -- Zflag,Cflag,Nflag
	end component;
---------------------------------------------------------
component SubAdder IS                                 --- SubAdder component
  GENERIC (n : INTEGER:= 8);
  PORT (    x,y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
			ALU_func: std_logic_vector (2 downto 0);
            cout: OUT STD_LOGIC;
            s: OUT STD_LOGIC_VECTOR(n-1 downto 0));
END component;
--------------------------------------------------------- 
component logic is									  --- Logic component
	GENERIC (n : INTEGER:= 8);
	port(x, y: in std_logic_vector (n-1 downto 0);
	ALU_func: std_logic_vector (2 downto 0);
	res : out std_logic_vector(n-1 downto 0));
	end component;
---------------------------------------------------------
component shifter is								 --- Shifter component
 GENERIC (n : INTEGER := 8; k : integer := 3); -- k = log2(n) 
port (x,y : in std_logic_vector (n-1 downto 0);
	ALU_func: in std_logic_vector (2 downto 0);
	res : out std_logic_vector (n-1 downto 0);
	cout : out std_logic);
end component; 
---------------------------------------------------------
	component FA is									--- FA component: used in SubAdder implementation
		PORT (xi, yi, cin: IN std_logic;
			      s, cout: OUT std_logic);
	end component;
---------------------------------------------------------	

	 	
	
end ALU_aux_package;

