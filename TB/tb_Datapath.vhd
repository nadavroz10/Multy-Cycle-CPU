library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
USE work.aux_package.all;
--------------------------------------
------------------------------------
entity tb_Datapath is
	constant n: integer:= BUSwidth; 
	constant m: integer:= 4;  -- k=log2(n)
	constant k: integer:= 8;  -- m=2^(k-1)
	constant dataIn_tb_size:integer := 53;  -- size of tb data in vector 
end tb_Datapath;

----------------------------------------------------------------------------------
architecture tbDat_arch of tb_Datapath is
    signal control: std_logic_vector(control_vec_size-1 downto 0);
	signal rst, clk:  std_logic;
	signal dataIn_tb:  std_logic_vector( dataIn_tb_size-1 downto 0);  --tb vector
	signal status:  std_logic_vector(status_vec_size -1 downto 0);
	signal dataOut_tb:  std_logic_vector( n-1 downto 0);  --tb vector
	signal finished_InitDat, finished_InitProg: std_logic := '0';
	constant DTCMinit_loc: string (1 to 79) := "C:\Users\nadav\Desktop\LAB3-20230429T072547Z-001\LAB3\Memory files\DTCMinit.txt";
	constant ITCMinit_loc: string (1 to 83) := "C:\Users\nadav\Desktop\LAB3-20230429T072547Z-001\LAB3\Memory files\Minit_dat_tb.txt";

	
	
begin
Datapath_DUT: Datapath generic map (n,m,k) port map (control, rst, clk, dataIn_tb, status, dataOut_tb );

cpu_clk : process
			begin
				clk <= '0';
				wait for 50 ns ;
				clk <= not clk;
				wait for 50 ns ;
			end process;

-------------------------------------------------------------------------------------------

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
			
------------------------------------------------------------------------------------------
control_gen : process
			begin
				wait until finished_InitProg = '1' and finished_InitDat = '1';
				------mov r1, 10----
				wait until CLK = '0';
				wait until CLK = '1';
				control<= (IRin => '1' , others => '0');
				wait until CLK = '0';
				wait until CLK = '1';
				control<= (RFaddr_1 => '0' ,RFaddr_0 => '1' , RFout => '1',Ain => '1', others => '0');
				wait until CLK = '0';
				wait until CLK = '1';
				control<= (Imm1_in => '1',RFin => '1',PCin => '1' , others => '0');
				wait until CLK = '0';
				wait until CLK = '1';
				------ ld r2, 0(r4)----
				control<= (IRin => '1' , others => '0');
				wait until CLK = '0';
				wait until CLK = '1';
				control<= (RFaddr_1 => '0' ,RFaddr_0 => '1' , RFout => '1',Ain => '1', others => '0');
				wait until CLK = '0';
				wait until CLK = '1';
				control<= (Imm2_in => '1',Cin => '1' , others => '0');
				wait until CLK = '0';
				wait until CLK = '1';
				control<= (Cout => '1' , others => '0');
				wait until CLK = '0';
				wait until CLK = '1';
				control<= (Mem_out => '1',RFin => '1',PCin => '1' , others => '0');
				wait until CLK = '0';
				wait until CLK = '1';
				------add r3, r1, r2--------
				control<= (IRin => '1' , others => '0');
				wait until CLK = '0';
				wait until CLK = '1';
				control<= (RFaddr_1 => '0' ,RFaddr_0 => '1' , RFout => '1',Ain => '1', others => '0');
				wait until CLK = '0';
				wait until CLK = '1';
				control<= (RFout => '1',Cin => '1' ,RFaddr_1 => '1' ,RFaddr_0 => '0', others => '0');
				wait until CLK = '0';
				wait until CLK = '1';
				control<= (Cout => '1' ,RFin => '1',PCin => '1', others => '0');
				wait;
			end process;

-----------------------------------------------------------------------------------------
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

-----------------------------------------------------------------------------------------
			TB_gen :process
			begin
			dataIn_tb(TBactive) <= '1';  -- START INIT
			rst <= '1';
			wait until finished_InitProg = '1' and finished_InitDat = '1';
			-----------------------------
			dataIn_tb(TBactive) <= '0';  -- START Program
			rst <= '0';
			wait;
			end process;





end tbDat_arch;