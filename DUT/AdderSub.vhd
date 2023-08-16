LIBRARY ieee;
USE ieee.std_logic_1164.all;
-------------------------------------
ENTITY SubAdder IS
  GENERIC (n : INTEGER:= 8);
  PORT (    x,y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
			ALU_func: std_logic_vector (2 downto 0);
            cout: OUT STD_LOGIC;
            s: OUT STD_LOGIC_VECTOR(n-1 downto 0));
END SubAdder;
--------------------------------------------------------------

ARCHITECTURE dfl OF SubAdder IS
	component FA is
		PORT (xi, yi, cin: IN std_logic;
			      s, cout: OUT std_logic);
	end component;
	SIGNAL reg : std_logic_vector(n-1 DOWNTO 0);
	signal x_demo, y_demo: std_logic_vector(n-1 DOWNTO 0);
	signal cin_demo: std_logic;
	signal is_valid: std_logic;    ---is_valid is 1 if ALU_func is valid, 0 otherwise
BEGIN
	with ALU_func select
		is_valid <= '1' when "000" | "001" | "010",     ---is_valid is 1 if ALU_func is valid, 0 otherwise
					'0' when others;
	cin_demo <= (ALU_func(1) or ALU_func(0)) and is_valid; -- 1 for SUB or NEG, 0 for ADD
	alu_func_ctr: for j in 0 to n-1 generate
		x_demo(j) <=  (x(j) xor (ALU_func(1) or ALU_func(0))) and is_valid;  --- two's comlement
		y_demo(j) <=  (y(j) and not(ALU_func(1))) and is_valid;   --- If the wanted ALU function is NEG, make y zero
	end generate;
	
	first : FA port map(                                         --- First FA
		xi => x_demo(0),
		yi => y_demo(0),
		s => s(0),
		cin =>  cin_demo,
		cout => reg(0)
	);

	rest : for i in 1 to n-1 generate							--- The rest of the full adders
		chain : FA port map(
			xi => x_demo(i),
			yi => y_demo(i),
			cin => reg(i-1),
			s => s(i),
			cout => reg(i)
		);
	end generate;
cout <= reg(n-1);
END dfl;
