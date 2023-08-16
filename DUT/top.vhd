LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.aux_package.all;
---------------------------------------------

entity top is
	generic(n: integer:= BUSwidth; 
			m: integer:= 4;  -- k=log2(n)
			k: integer:= 8  -- m=2^(k-1)
			);
	PORT ( 	ena, clk, rst: IN STD_LOGIC;
			dataIn_tb: in std_logic_vector( dataIn_tb_size-1 downto 0);
			done_out: OUT STD_LOGIC;
			dataOut_tb: out std_logic_vector( n-1 downto 0)
			);
	
	END top;

architecture top_arch of top is
	signal control_vec : std_logic_vector (control_vec_size -1 downto 0);
	signal status_vec : std_logic_vector (status_vec_size -1 downto 0);
	-----------
	signal DWena, PWena, TBActive_sig:  STD_LOGIC;
	signal data_write_vec, program_write_vec: STD_LOGIC_VECTOR (n -1 downto 0);
	signal data_write_addr, program_write_addr: STD_LOGIC_VECTOR (Awidth -1 downto 0);
	
	
	begin
		datapath_conn: Datapath generic map (n,m,k) port map(control_vec, rst, clk, dataIn_tb, status_vec, dataOut_tb);
		control_conn: control  port map (ena, clk, rst, status_vec, control_vec, done_out);

		---------------------------------
		TBActive_sig <= dataIn_tb(TBactive);
		
		data_write_addr<= dataIn_tb(tb_Dwriteaddr_msb downto tb_Dwriteaddr_0);
		DWena <= dataIn_tb(tb_Dwena);
		data_write_vec <= dataIn_tb(tb_DdataIN_msb downto tb_DdataIN_0);
		
		program_write_addr<= dataIn_tb(tb_Pwriteaddr_msb downto tb_Pwriteaddr_0);
		PWena <= dataIn_tb(tb_Pwena);
		program_write_vec <= dataIn_tb(tb_PdataIN_msb downto tb_PdataIN_0);

end top_arch;