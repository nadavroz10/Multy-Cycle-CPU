library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
USE work.aux_package.all;

------------------------------------
entity tb is
	constant n: integer:= BUSwidth; 
	constant m: integer:= 4;  -- k=log2(n)
	constant k: integer:= 8;  -- m=2^(k-1)
	constant dataIn_tb_size:integer := 53;  -- size of tb data in vector 
end tb;

------------------------------------
architecture tb_arch of tb is
	--signal write_gen : boolean := true; 
	signal ena, clk, rst:  STD_LOGIC;
	signal dataIn_tb:  std_logic_vector( dataIn_tb_size-1 downto 0);
	signal done_out:  STD_LOGIC;
	signal dataOut: STD_LOGIC_VECTOR (n -1 downto 0);
	constant ITCMinit_loc: string (1 to 79) := "C:\Users\nadav\Desktop\LAB3-20230429T072547Z-001\LAB3\Memory files\ITCMinit.txt";
	constant DTCMinit_loc: string (1 to 79) := "C:\Users\nadav\Desktop\LAB3-20230429T072547Z-001\LAB3\Memory files\DTCMinit.txt";
	constant DTCMcontent_loc: string (1 to 82) := "C:\Users\nadav\Desktop\LAB3-20230429T072547Z-001\LAB3\Memory files\DTCMcontent.txt";
	signal finished_InitDat, finished_InitProg: std_logic := '0';

	begin
		DUT_CONN: top generic map (n,m,k) port map (ena, clk, rst, dataIn_tb, done_out, dataOut );
		--write_gen <= not (write_gen) after 50 ns;
		
		cpu_clk : process
			begin
				clk <= '0';
				wait for 50 ns ;
				clk <= not clk;
				wait for 50 ns ;
			end process;
		
		
		-------------------------------------------------------------------------------
		init_Dmem: process 
			file DTCMinit: text open read_mode is DTCMinit_loc;
			variable L, temp_L : line;
			variable data_write_addr: std_logic_vector(Awidth -1 downto 0);
			variable data_var :std_logic_vector(n -1 downto 0);
			variable good: boolean;
			begin
		       
				-------Data MEM-------
				data_write_addr := "000000";
				while not endfile (DTCMinit) loop
					wait until (clk'event and clk = '1');
					readline (DTCMinit, L);
					HREAD (L, data_var, good);
					dataIn_tb(tb_Dwena) <= '1';
					dataIn_tb(tb_DdataIN_msb downto tb_DdataIN_0) <= data_var;
					--dataIn_tb(tb_Dwena) <= '0';
					dataIn_tb(tb_Dwriteaddr_msb downto tb_Dwriteaddr_0) <= data_write_addr;
					data_write_addr := data_write_addr + "000001";
					end loop;
					
				file_close(DTCMinit);   --- close file
				finished_InitDat <= '1';
				wait;
			end process;	
		--------------------------------------------------------------------------------------			
			
		init_Pmem: process 
			variable program_write_addr: std_logic_vector(Awidth -1 downto 0);	
			file ITCMinit: text open read_mode is ITCMinit_loc;
			variable  command_var:std_logic_vector(n -1 downto 0);
			variable L, temp_L : line;
			variable good: boolean;
			begin
			-------Program MEM-------
				program_write_addr := "000000";
				while not endfile (ITCMinit) loop
					wait until (clk'event and clk = '1');
					readline (ITCMinit, L);
					HREAD (L, command_var, good);
					dataIn_tb(tb_Pwena) <= '1';
					dataIn_tb(tb_PdataIN_msb downto tb_PdataIN_0) <=  command_var;
					--dataIn_tb(tb_Pwena) <= '0';
					dataIn_tb(tb_Pwriteaddr_msb downto tb_Pwriteaddr_0) <= program_write_addr;
					program_write_addr := program_write_addr + "000001";
					end loop;
				
				file_close(ITCMinit);
				finished_InitProg <= '1';
				wait;
			end process;
		
		--------------------------------------------------------------------------------------------
		
		
		TB_gen :process
			begin
			dataIn_tb(TBactive) <= '1';  -- START INIT
			rst <= '1';
			ena <= '0'; -- ena to control
			wait until finished_InitProg = '1' and finished_InitDat = '1';
			-----------------------------
			dataIn_tb(TBactive) <= '0';  -- START Program
			rst <= '0';
			ena <= '1'; -- ena to control
			-----------------------------
			wait until done_out = '1'; 
			--dataIn_tb(TBactive) <= '1';  -- START READING CONTENT
			rst <= '1';
			ena <= '0'; -- ena to control			
			end process;

		----------------------------------------------------------------------------------------------
			
		read_content: process
			file DTCMcontent: text open write_mode is DTCMcontent_loc;
			variable L_w : line;
			variable data_read_addr: std_logic_vector(Awidth -1 downto 0);
			variable data_content: std_logic_vector (n-1 downto 0);
			variable count: integer;
			begin
				data_read_addr := "000000";
				count := 0;
				wait until done_out = '1';   -- strart reading only when the program is finished
				
				while (count < 64) loop
					wait for 200 ns;
					wait until (clk'event and clk = '1');
					dataIn_tb(tb_Dreadaddr_msb downto tb_Dreadaddr_0) <= data_read_addr ;  -- address to read
					wait for 200 ns;
					wait until (clk'event and clk = '1');
					data_content := dataOut;
					HWRITE(L_w, conv_std_logic_vector(conv_integer(data_content), n));
					writeline(DTCMcontent, L_w);
					wait for 200 ns;
					data_read_addr := data_read_addr + "000001";
					count := count + 1;
				end loop;
				file_close(DTCMcontent);  --- close file
				wait;
			end process;
			
end tb_arch;