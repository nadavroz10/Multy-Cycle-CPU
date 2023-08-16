LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALU_aux_package.all;
-------------------------------------
ENTITY ALU IS
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
END ALU;
--------------------------------------
ARCHITECTURE struct OF ALU IS 	
signal shift_out, suba_out, logic_out,ALU_out_demo: std_logic_vector (n-1 downto 0); --- A buffer signal to each module:Logic, SubAdder, Shifter
signal cshift, cadd : std_logic;     --- Cout buffers signals. cshift for Shifter and cadd for SubAdder
signal zero_vector: std_logic_vector(n-1 DOWNTO 0); --- Zero's vector to calculate Zflag
BEGIN
	sub_add: SubAdder generic map(n) port map(   --- SubAdder connection to the top system.
	x => x_i,
	y => y_i,
	ALU_func => ALUFN_i(2 downto 0),
	cout => cadd,
	s => suba_out
	);
	logic_lbl: logic generic map(n) port map(    --- Logic connection to the top system.
	x => x_i,
	y => y_i,
	ALU_func => ALUFN_i(2 downto 0),
	res => logic_out
	);
	shift_lbl: shifter generic map(n,k) port map( --- Shifter connection to the top system.
	x => x_i,
	y => y_i,
	ALU_func => ALUFN_i(2 downto 0),
	res => shift_out,
	cout => cshift
	);
	
	with ALUFN_i(4 downto 3) select               --- Defining output according to ALUFN_i[4:3]
		ALU_out_demo <= logic_out when "11",
				 shift_out when "10",
				 suba_out when "01",
				 unaffected when others; --- When ALUFN_i[4:3] is undefined, the output does'nt change
				 
	with ALUFN_i(4 downto 3) select
		Cflag_o <= cshift when "10",
				 cadd when "01",
				 '0' when "11",
				 unaffected when others; --- When ALUFN_i[4:3] is undefined, the output does'nt change
	
	 
	 
	 Nflag_o <=ALU_out_demo(n-1) when ((ALUFN_i(4 downto 3) = "01") or (ALUFN_i(4 downto 3) = "11") or (ALUFN_i(4 downto 3) = "10")) else 
	 unaffected;     --- Nflag calculation. Does not change when ALUFN_i[4:3] is undefined
	 
	 Create_Zeros: for i in 0 to n-1 generate  --- Creating n size zeros vector, for calculating ZFLAG.
		zero_vector(i) <= '0';
	end generate;
	
	 
	 Zflag_o <= '1' when (ALU_out_demo = zero_vector) and ((ALUFN_i(4 downto 3) = "01") or (ALUFN_i(4 downto 3) = "11") or (ALUFN_i(4 downto 3) = "10"))
	 else '0' when ((ALUFN_i(4 downto 3) = "01") or (ALUFN_i(4 downto 3) = "11") or (ALUFN_i(4 downto 3) = "10"))
	 else unaffected; --- Zflag calculation. Does not change when ALUFN_i[4:3] is undefined
	 
	 ALUout_o <= ALU_out_demo;
	 
END struct;

